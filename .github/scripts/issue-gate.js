// Holds issues to the forms in .github/ISSUE_TEMPLATE: labels an incomplete one `needs-info` with a comment,
// closes it 7 days later, and locks every issue 30 days after it closed. Issues opened or closed before GATE_SINCE,
// the day the gate reached main, are left as they were. Run by .github/workflows/issue-gate.yaml.
const fs = require('fs');
const path = require('path');

const NEEDS_INFO = 'needs-info';
const MARKER = '<!-- issue-gate -->';
const CLOSE_AFTER_DAYS = 7;
const LOCK_AFTER_DAYS = 30;
const UNRELEASED_COMMIT_DAYS = 30;
const DAY_MS = 24 * 60 * 60 * 1000;
const EXEMPT = ['OWNER', 'MEMBER', 'COLLABORATOR'];
const EMPTY = '_No response_';
const GATE_SINCE = '2026-11-20';
// The tags .github/workflows/build.yaml publishes: vX.Y.Z, and a prerelease vX.Y.Z-pre.N with a rebuild +M.
const RELEASE = /^v?(\d+)\.(\d+)\.(\d+)(?:-pre\.(\d+)(?:\+(\d+))?)?$/;

function unquote(text) {
  const trimmed = text.trim();
  return /^(["']).*\1$/.test(trimmed) ? trimmed.slice(1, -1) : trimmed;
}

// The fields of one issue form: each one's heading, whether it is required, and for checkboxes the required options.
function parseForm(text) {
  const form = { title: '', labels: [], fields: [] };
  let field = null;
  let option = null;
  for (const line of text.split('\n')) {
    const title = line.match(/^title:\s*(.+)$/);
    if (title) form.title = unquote(title[1]);
    const labels = line.match(/^labels:\s*\[(.*)\]\s*$/);
    if (labels) form.labels = labels[1].split(',').map(unquote).filter(Boolean);
    const type = line.match(/^ {2}- type:\s*(\S+)/);
    if (type) {
      field = { type: type[1], id: '', heading: '', required: false, options: [] };
      option = null;
      if (field.type !== 'markdown') form.fields.push(field);
      continue;
    }
    if (!field) continue;
    const id = line.match(/^ {4}id:\s*(.+)$/);
    if (id) field.id = unquote(id[1]);
    const heading = line.match(/^ {6}label:\s*(.+)$/);
    if (heading) field.heading = unquote(heading[1]);
    if (/^ {6}required:\s*true\s*$/.test(line)) field.required = true;
    const choice = line.match(/^ {8}- label:\s*(.+)$/);
    if (choice) {
      option = { label: unquote(choice[1]), required: false };
      field.options.push(option);
    }
    if (option && /^ {10}required:\s*true\s*$/.test(line)) option.required = true;
  }
  return form;
}

function loadForms(root) {
  const dir = path.join(root, '.github', 'ISSUE_TEMPLATE');
  return fs
    .readdirSync(dir)
    .filter((name) => name.endsWith('.yml') && name !== 'config.yml')
    .sort()
    .map((name) => ({ name, ...parseForm(fs.readFileSync(path.join(dir, name), 'utf8')) }));
}

// The body an issue form writes: `### <heading>` and the value below it, up to the next heading.
function sections(body) {
  const found = new Map();
  const parts = (body || '').replace(/\r\n/g, '\n').split(/^### /m).slice(1);
  for (const part of parts) {
    const newline = part.indexOf('\n');
    const heading = (newline < 0 ? part : part.slice(0, newline)).trim();
    found.set(heading, newline < 0 ? '' : part.slice(newline + 1).trim());
  }
  return found;
}

function matchForm(forms, labels, found) {
  const byLabel = forms.find((form) => form.labels.some((label) => labels.includes(label)));
  if (byLabel) return byLabel;
  return forms.find((form) => form.fields.every((field) => found.has(field.heading)));
}

// What is missing from `body` for `form`, in the words the comment uses.
function formProblems(form, found) {
  const problems = [];
  for (const field of form.fields) {
    const value = found.get(field.heading);
    if (value === undefined) {
      problems.push(`缺少这一节 / Missing section: ${field.heading}`);
      continue;
    }
    if (field.type === 'checkboxes') {
      for (const option of field.options.filter((o) => o.required)) {
        const ticked = value.split('\n').some((line) => {
          const box = line.match(/^- \[([xX ])\] (.*)$/);
          return box && box[1] !== ' ' && box[2].trim() === option.label;
        });
        if (!ticked) problems.push(`未勾选 / Not ticked: ${option.label}`);
      }
    } else if (field.required && (value === '' || value === EMPTY || /^```\w*\s*```$/.test(value))) {
      problems.push(`未填写 / Empty: ${field.heading}`);
    }
  }
  return problems;
}

// A title that is only the form's prefix says nothing; GitHub requires a title but not past the prefill.
function titleProblems(form, title) {
  const prefix = form.title.trim();
  let rest = (title || '').trim();
  if (prefix && rest.toLowerCase().startsWith(prefix.toLowerCase())) rest = rest.slice(prefix.length).trim();
  if (rest !== '') return [];
  return [`标题：在 ${prefix} 后面用一句话写清问题 / Title: add a one-line summary after ${prefix}`];
}

// Ordered as compared: a release ranks above each of its prereleases.
function releaseOf(value) {
  const match = value.match(RELEASE);
  if (!match) return null;
  const [major, minor, patch, pre, rebuild] = match.slice(1);
  return [major, minor, patch, pre ?? Infinity, rebuild ?? 0].map(Number);
}

function olderThan(a, b) {
  const index = a.findIndex((part, i) => part !== b[i]);
  return index >= 0 && a[index] < b[index];
}

// A version must be the latest release or newer; a commit must be on main and no older than the latest release, or
// than UNRELEASED_COMMIT_DAYS while there is no release.
async function versionProblems(github, repo, value) {
  let latest = null;
  try {
    latest = (await github.rest.repos.getLatestRelease(repo)).data;
  } catch (error) {
    if (error.status !== 404) throw error;
  }
  const tag = latest ? ` ${latest.tag_name}` : '';
  const wanted =
    `版本：填“工具 → 关于”里的版本号，并在最新版${tag}或更新的版本上复现。/ ` +
    `Version: give the version from Tools → About, reproduced on the latest release${tag} or newer.`;
  const release = releaseOf(value);
  if (release) {
    const newest = latest && releaseOf(latest.tag_name);
    return newest && olderThan(release, newest) ? [wanted] : [];
  }
  if (!/^[0-9a-f]{40}$/.test(value)) return [wanted];
  let commit;
  try {
    const compare = await github.rest.repos.compareCommitsWithBasehead({ ...repo, basehead: `${value}...main` });
    if (!['ahead', 'identical'].includes(compare.data.status)) return [wanted];
    commit = compare.data.base_commit;
  } catch (error) {
    if (error.status === 404 || error.status === 422) return [wanted];
    throw error;
  }
  const committed = Date.parse(commit.commit.committer.date);
  const since = latest ? Date.parse(latest.published_at) : Date.now() - UNRELEASED_COMMIT_DAYS * DAY_MS;
  return committed >= since ? [] : [wanted];
}

async function problemsOf(github, repo, issue, forms) {
  const labels = issue.labels.map((label) => (typeof label === 'string' ? label : label.name));
  const found = sections(issue.body);
  const form = matchForm(forms, labels, found);
  if (!form) return ['没有通过 issue 表单提交 / Not opened through one of the issue forms.'];
  const problems = [...titleProblems(form, issue.title), ...formProblems(form, found)];
  const version = form.fields.find((field) => field.id === 'version');
  const value = version && found.get(version.heading);
  if (value && value !== EMPTY) problems.push(...(await versionProblems(github, repo, value)));
  return problems;
}

function message(problems, newIssueUrl) {
  return [
    MARKER,
    `这个 issue 缺少必要信息，已标记 \`${NEEDS_INFO}\`：`,
    `This issue is labelled \`${NEEDS_INFO}\` because it is incomplete:`,
    '',
    ...problems.map((problem) => `- ${problem}`),
    '',
    `编辑 issue 补全后标记会自动去掉；标记满 ${CLOSE_AFTER_DAYS} 天仍未补全的 issue 会被关闭。新 issue 请用表单：${newIssueUrl}`,
    '',
    `Edit the issue to complete it, and the label is removed. An issue still labelled \`${NEEDS_INFO}\` ` +
      `${CLOSE_AFTER_DAYS} days after it was labelled is closed. New issues go through the forms: ${newIssueUrl}`,
  ].join('\n');
}

async function check({ github, context, root }) {
  const issue = context.payload.issue;
  if (issue.pull_request || issue.state !== 'open' || EXEMPT.includes(issue.author_association)) return;
  if (issue.created_at < GATE_SINCE) return;
  const repo = context.repo;
  const problems = await problemsOf(github, repo, issue, loadForms(root));
  const labelled = issue.labels.some((label) => label.name === NEEDS_INFO);
  const comments = await github.paginate(github.rest.issues.listComments, { ...repo, issue_number: issue.number });
  const mine = comments.find((comment) => comment.user.type === 'Bot' && comment.body.startsWith(MARKER));
  if (problems.length === 0) {
    if (labelled) {
      await github.rest.issues.removeLabel({ ...repo, issue_number: issue.number, name: NEEDS_INFO });
    }
    if (mine) await github.rest.issues.deleteComment({ ...repo, comment_id: mine.id });
    return;
  }
  const body = message(problems, `${context.payload.repository.html_url}/issues/new/choose`);
  if (mine) {
    if (mine.body !== body) await github.rest.issues.updateComment({ ...repo, comment_id: mine.id, body });
  } else {
    await github.rest.issues.createComment({ ...repo, issue_number: issue.number, body });
  }
  if (!labelled) {
    await github.rest.issues.addLabels({ ...repo, issue_number: issue.number, labels: [NEEDS_INFO] });
  }
}

async function sweep({ github, context, now = Date.now() }) {
  const repo = context.repo;
  const open = await github.paginate(github.rest.issues.listForRepo, {
    ...repo,
    state: 'open',
    labels: NEEDS_INFO,
  });
  for (const issue of open.filter((item) => !item.pull_request)) {
    const events = await github.paginate(github.rest.issues.listEvents, { ...repo, issue_number: issue.number });
    const labelled = events
      .filter((event) => event.event === 'labeled' && event.label && event.label.name === NEEDS_INFO)
      .map((event) => Date.parse(event.created_at));
    if (labelled.length === 0 || now - Math.max(...labelled) < CLOSE_AFTER_DAYS * DAY_MS) continue;
    await github.rest.issues.update({
      ...repo,
      issue_number: issue.number,
      state: 'closed',
      state_reason: 'not_planned',
    });
  }
  const last = new Date(now - (LOCK_AFTER_DAYS + 1) * DAY_MS).toISOString().slice(0, 10);
  if (last < GATE_SINCE) return;
  const stale = await github.paginate(github.rest.search.issuesAndPullRequests, {
    q: `repo:${repo.owner}/${repo.repo} is:issue is:closed is:unlocked closed:${GATE_SINCE}..${last}`,
  });
  for (const issue of stale) {
    await github.rest.issues.lock({ ...repo, issue_number: issue.number });
  }
}

module.exports = { check, sweep, parseForm, sections, formProblems, titleProblems, problemsOf, matchForm, loadForms };
