const assert = require('node:assert/strict');
const path = require('node:path');
const test = require('node:test');
const gate = require('./issue-gate.js');

const root = path.join(__dirname, '..', '..');
const forms = gate.loadForms(root);
const repo = { owner: 'chen08209', repo: 'FlClash' };
const github = {
  rest: {
    repos: {
      getLatestRelease: async () => ({ data: { tag_name: 'v0.9.4', published_at: '2026-11-19T00:00:00Z' } }),
    },
  },
};

function form(name) {
  return forms.find((item) => item.name === name);
}

function completeBody(of) {
  return of.fields
    .map((field) => {
      const value =
        field.type === 'checkboxes'
          ? field.options.map((option) => `- [X] ${option.label}`).join('\n')
          : field.id === 'version'
            ? 'v0.9.4'
            : 'filled';
      return `### ${field.heading}\n\n${value}`;
    })
    .join('\n\n');
}

function issue(name, title) {
  const of = form(name);
  return { title, body: completeBody(of), labels: of.labels.map((label) => ({ name: label })) };
}

async function problems(name, title) {
  return gate.problemsOf(github, repo, issue(name, title), forms);
}

test('the forms prefill the prefixes the title check strips', () => {
  assert.equal(form('bug_report.yml').title, '[BUG] ');
  assert.equal(form('feature_request.yml').title, '[Feature] ');
});

test('a complete issue with a real title has no problems', async () => {
  assert.deepEqual(await problems('bug_report.yml', '[BUG] The app crashes on start'), []);
  assert.deepEqual(await problems('feature_request.yml', '[Feature] Sort proxies by name'), []);
  assert.deepEqual(await problems('bug_report.yml', 'Crash on start'), []);
});

function withVersion(version) {
  const of = form('bug_report.yml');
  const reported = issue('bug_report.yml', '[BUG] The app crashes on start');
  const heading = of.fields.find((field) => field.id === 'version').heading;
  return { ...reported, body: reported.body.replace(`### ${heading}\n\nv0.9.4`, `### ${heading}\n\n${version}`) };
}

test('a prerelease the latest release does not supersede is a version to report from', async () => {
  for (const version of ['v0.9.5-pre.1', 'v0.9.5-pre.2+1', '0.9.5-pre.3']) {
    assert.deepEqual(await gate.problemsOf(github, repo, withVersion(version), forms), [], version);
  }
});

test('a prerelease of the latest release or older is not', async () => {
  for (const version of ['v0.9.4-pre.3', 'v0.9.4-pre.3+1', 'v0.9.3-pre.1', 'v0.9.5-rs.1', 'v0.9.5-pre']) {
    const found = await gate.problemsOf(github, repo, withVersion(version), forms);
    assert.equal(found.length, 1, version);
    assert.match(found[0], /^版本/, version);
  }
});

test('a title that is only the prefix is a problem, whatever its case or spacing', async () => {
  for (const [name, title] of [
    ['bug_report.yml', '[BUG] '],
    ['bug_report.yml', '  [bug]'],
    ['bug_report.yml', ''],
    ['feature_request.yml', '[Feature]'],
  ]) {
    const found = await problems(name, title);
    assert.equal(found.length, 1, `${name} ${JSON.stringify(title)}`);
    assert.match(found[0], /^标题：.*Title: add a one-line summary after \[/);
  }
});

function recorder() {
  const calls = [];
  const record = (name) => async (args) => {
    calls.push([name, args]);
    return { data: {} };
  };
  return {
    calls,
    github: {
      paginate: async () => [],
      rest: {
        repos: github.rest.repos,
        issues: {
          listComments: null,
          createComment: record('createComment'),
          updateComment: record('updateComment'),
          deleteComment: record('deleteComment'),
          addLabels: record('addLabels'),
          removeLabel: record('removeLabel'),
        },
      },
    },
  };
}

function context(payloadIssue) {
  return {
    repo,
    payload: {
      issue: {
        number: 1,
        state: 'open',
        author_association: 'NONE',
        created_at: '2026-11-21T00:00:00Z',
        ...payloadIssue,
      },
      repository: { html_url: 'https://github.com/chen08209/FlClash' },
    },
  };
}

test('a bare prefix title labels the issue needs-info and says so in the comment', async () => {
  const { calls, github: stub } = recorder();
  await gate.check({ github: stub, context: context(issue('bug_report.yml', '[BUG] ')), root });
  const comment = calls.find(([name]) => name === 'createComment');
  assert.ok(comment);
  assert.match(comment[1].body, /Title: add a one-line summary after \[BUG\]/);
  assert.deepEqual(calls.find(([name]) => name === 'addLabels')[1].labels, ['needs-info']);
});

test('giving the title clears the label once nothing else is missing', async () => {
  const { calls, github: stub } = recorder();
  const fixed = issue('bug_report.yml', '[BUG] The app crashes on start');
  fixed.labels.push({ name: 'needs-info' });
  await gate.check({ github: stub, context: context(fixed), root });
  assert.deepEqual(
    calls.map(([name]) => name),
    ['removeLabel'],
  );
});
