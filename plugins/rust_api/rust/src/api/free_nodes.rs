use crate::frb_generated::StreamSink;
use base64::engine::general_purpose::{STANDARD, URL_SAFE, URL_SAFE_NO_PAD};
use base64::Engine;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;
use serde::{Deserialize, Serialize};
use serde_json::{json, Map, Value};
use std::borrow::Cow;
use std::collections::{HashMap, HashSet, VecDeque};
use std::fmt::Write as _;
use std::sync::atomic::{AtomicUsize, Ordering};
use std::sync::mpsc;
use std::sync::{Arc, Condvar, Mutex};
use std::thread;
use std::time::{Duration, Instant};
use ureq::{Agent, Proxy};
use url::Url;

const FREE_NODES_GROUP_NAME: &str = "FREE-NODES";
const FREE_NODES_HISTORY_GROUP_NAME: &str = "历史";
const FREE_NODES_DATE_GROUP_PREFIX: &str = "日期 ";
const FREE_NODES_TREASURE_GROUP_NAME: &str = "优选节点";
const FREE_NODES_LEGACY_TREASURE_GROUP_NAME: &str = "宝藏积累";
const FREE_NODES_SOURCE_GROUP_PREFIX: &str = "来源 ";
const DEFAULT_TEST_URL: &str = "https://www.gstatic.com/generate_204";
const DEFAULT_MIXED_PORT: i64 = 7890;
const DISCOVERY_CONFIG_THRESHOLD: usize = 30;
const FAST_DISCOVERY_PAGE_LIMIT: usize = 36;
const FULL_DISCOVERY_PAGE_LIMIT: usize = 72;
const MIN_DISCOVERY_PAGES_PER_SOURCE: usize = 3;
const CONFIG_CANDIDATE_CANONICAL_LIMIT: usize = 100;
const MAX_EQUIVALENT_FETCH_CANDIDATES: usize = GITHUB_RAW_MIRROR_PREFIXES.len()
    + GITHUB_PATH_MIRROR_PREFIXES.len()
    + GITHUB_RAW_PATH_MIRROR_PREFIXES.len()
    + 1;
const CONFIG_CANDIDATE_LIMIT: usize =
    MAX_EQUIVALENT_FETCH_CANDIDATES * CONFIG_CANDIDATE_CANONICAL_LIMIT;
const PROVIDER_FOLLOWUP_FETCH_LIMIT: usize = 16;
const EMBEDDED_BASE64_MIN_LEN: usize = 32;
const EMBEDDED_BASE64_MAX_LEN: usize = 128 * 1024;
const DECODED_CANDIDATE_LIMIT: usize = 16;
const DECIMAL_BYTE_STREAM_MIN_TOKENS: usize = 12;
const DISCOVERY_URL_INITIAL_CAPACITY: usize = 16;
const FREE_NODES_RESPONSE_BODY_LIMIT_BYTES: u64 = 64 * 1024 * 1024;
const GITHUB_RAW_MIRROR_PREFIXES: [&str; 13] = [
    "https://gh.llkk.cc/",
    "https://ghfast.top/",
    "https://ghproxy.net/",
    "https://gh-proxy.com/",
    "https://ghproxy.imciel.com/",
    "https://gh.monlor.com/",
    "https://gh.ddlc.top/",
    "https://ghfile.geekertao.top/",
    "https://ghproxy.cc/",
    "https://gh.con.sh/",
    "https://hub.gitmirror.com/",
    "https://ghproxy.vip/",
    "https://github.akams.cn/",
];
const GITHUB_PATH_MIRROR_PREFIXES: [&str; 3] = [
    "https://gcore.jsdelivr.net/gh/",
    "https://fastly.jsdelivr.net/gh/",
    "https://cdn.jsdelivr.net/gh/",
];
const GITHUB_RAW_PATH_MIRROR_PREFIXES: [&str; 1] = ["https://rawgithubusercontent.deno.dev/"];
const AUTO_GITHUB_SEED_EXPANSION_RAW_CANDIDATE_LIMIT: usize = 5;
const GITHUB_RAW_SEED_PATHS: &[&str] = &[
    "clash.yaml",
    "clash.yml",
    "clash.txt",
    "proxies.yaml",
    "proxies.yml",
    "mihomo.yaml",
    "mihomo.yml",
    "mihomo.txt",
    "clash-meta.yaml",
    "clash-meta.yml",
    "clash-meta.txt",
    "clashmeta.yaml",
    "clashmeta.yml",
    "clashmeta.txt",
    "meta.yaml",
    "meta.yml",
    "meta.txt",
    "config.yaml",
    "config.yml",
    "config.txt",
    "all.yaml",
    "all.yml",
    "all.json",
    "all.txt",
    "merged.yaml",
    "merged.yml",
    "merged.txt",
    "free.yaml",
    "free.yml",
    "free.json",
    "free.txt",
    "index.yaml",
    "index.yml",
    "index.txt",
    "base64.txt",
    "v2ray.txt",
    "c.yaml",
    "v.txt",
    "Client.txt",
    "v2",
    "ClashPremiumFree.yaml",
    "http.txt",
    "https.txt",
    "socks5.txt",
    "http.csv",
    "https.csv",
    "socks5.csv",
    "all-proxies.txt",
    "all.csv",
    "free.csv",
    "node.csv",
    "nodes.csv",
    "proxies.csv",
    "proxy.csv",
    "proxy.json",
    "proxies.json",
    "node.json",
    "nodes.json",
    "proxylist.txt",
    "proxylist.csv",
    "proxylist.json",
    "proxylist.yaml",
    "proxylist.yml",
    "proxylist.xml",
    "proxylist.phps",
    "proxy-list.txt",
    "proxy-list.csv",
    "proxy-list.json",
    "proxy-list.yaml",
    "proxy-list.yml",
    "proxy-list-raw.txt",
    "provider.yaml",
    "provider.yml",
    "provider.json",
    "providers.yaml",
    "providers.yml",
    "providers.json",
    "proxy-providers.yaml",
    "proxy-providers.yml",
    "proxy-providers.json",
    "proxy_providers.yaml",
    "proxy_providers.yml",
    "proxy_providers.json",
    "sub",
    "sub.yml",
    "sub_en",
    "sub_zh",
    "sub_ar",
    "v2ray",
    "base64",
    "list",
    "subscribe",
    "subscribe.txt",
    "subscribe.yaml",
    "subscribe.yml",
    "subscription",
    "subscription.txt",
    "subscription.yaml",
    "subscription.yml",
    "subscriptions",
    "subscriptions.txt",
    "subscriptions.yaml",
    "subscriptions.yml",
    "sub.txt",
    "sub.yaml",
    "sub1.txt",
    "sub2.txt",
    "sub3.txt",
    "node",
    "node.txt",
    "node.yaml",
    "node.yml",
    "nodes",
    "nodes.txt",
    "nodes.yaml",
    "nodes.yml",
    "proxy",
    "proxy.txt",
    "proxy.yaml",
    "proxy.yml",
    "proxies",
    "proxies.txt",
    "profile",
    "profile.txt",
    "profile.yaml",
    "profile.yml",
    "profiles",
    "profiles.txt",
    "profiles.yaml",
    "profiles.yml",
    "sing-box.json",
    "sing-box.yaml",
    "singbox.json",
    "outbounds.json",
    "outbounds.yaml",
    "source/clash-meta.yaml",
    "source/clash-meta-2.yaml",
    "static/sub_en",
    "static/sub_zh",
    "static/sub_ar",
    "sub/clash.yaml",
    "sub/clash.yml",
    "sub/proxies.yaml",
    "sub/proxies.yml",
    "sub/mihomo.yaml",
    "sub/mihomo.yml",
    "sub/base64.txt",
    "sub/merged.yaml",
    "sub/merged.yml",
    "sub/v2ray.txt",
    "sub/sub.txt",
    "sub/sub.yaml",
    "sub/protocols/vless.txt",
    "sub/protocols/vless.yaml",
    "sub/protocols/trojan.txt",
    "sub/protocols/trojan.yaml",
    "sub/protocols/vmess.txt",
    "sub/protocols/vmess.yaml",
    "sub/protocols/ss.txt",
    "sub/protocols/ss.yaml",
    "sub/protocols/hysteria2.txt",
    "sub/protocols/hysteria2.yaml",
    "output_configs/Vless.txt",
    "output_configs/Vmess.txt",
    "output_configs/Trojan.txt",
    "output_configs/ShadowSocks.txt",
    "output_configs/Hysteria2.txt",
    "output_configs/Tuic.txt",
    "Splitted-By-Protocol/vless.txt",
    "Splitted-By-Protocol/vmess.txt",
    "Splitted-By-Protocol/trojan.txt",
    "Splitted-By-Protocol/ss.txt",
    "Splitted-By-Protocol/hysteria2.txt",
    "Splitted-By-Protocol/tuic.txt",
    "sub/continents/Europe.txt",
    "sub/continents/Europe.yaml",
    "sub/continents/Asia.txt",
    "sub/continents/Asia.yaml",
    "sub/continents/NorthAmerica.txt",
    "sub/continents/NorthAmerica.yaml",
    "sub/countries/IR.txt",
    "sub/countries/IR.yaml",
    "sub/countries/US.txt",
    "sub/countries/US.yaml",
    "sub/countries/SG.txt",
    "sub/countries/SG.yaml",
    "sub/countries/HK.txt",
    "sub/countries/HK.yaml",
    "subscribe/clash.yaml",
    "subscribe/clash.yml",
    "subscribe/proxies.yaml",
    "subscribe/mihomo.yaml",
    "subscribe/base64.txt",
    "subscribe/v2ray.txt",
    "subscribe/sub.txt",
    "subscription/clash.yaml",
    "subscription/clash.yml",
    "subscription/proxies.yaml",
    "subscription/mihomo.yaml",
    "subscription/base64.txt",
    "subscriptions/clash.yaml",
    "subscriptions/clash.yml",
    "subscriptions/proxies.yaml",
    "subscriptions/mihomo.yaml",
    "subscriptions/base64.txt",
    "subscriptions/sub.txt",
    "subscriptions/v2ray/super-sub.txt",
    "subscriptions/v2ray/subs/sub1.txt",
    "subscriptions/v2ray/subs/sub2.txt",
    "subscriptions/v2ray/subs/sub3.txt",
    "subscriptions/v2ray/subs/sub4.txt",
    "subscriptions/v2ray/subs/sub5.txt",
    "subscriptions/v2ray/subs/sub6.txt",
    "subscriptions/v2ray/subs/sub7.txt",
    "subscriptions/v2ray/subs/sub8.txt",
    "subscriptions/v2ray/subs/sub9.txt",
    "subscriptions/v2ray/subs/sub10.txt",
    "node/clash.yaml",
    "node/clash.yml",
    "node/proxies.yaml",
    "node/proxies.yml",
    "node/mihomo.yaml",
    "node/base64.txt",
    "node/sub.txt",
    "node/v2ray.txt",
    "nodes/clashmeta.yaml",
    "nodes/v2rayshare.yaml",
    "nodes/yudou66.yaml",
    "nodes/yudou66.txt",
    "nodes/ndnode.txt",
    "nodes/v2rayshare.txt",
    "nodes/wenode.txt",
    "proxy/clash.yaml",
    "proxy/clash.yml",
    "proxy/proxies.yaml",
    "proxy/proxies.yml",
    "proxy/mihomo.yaml",
    "proxy/base64.txt",
    "proxy/sub.txt",
    "proxy/v2ray.txt",
    "proxies/clash.yaml",
    "proxies/clash.yml",
    "proxies/proxies.yaml",
    "proxies/proxies.yml",
    "proxies/mihomo.yaml",
    "proxies/base64.txt",
    "proxies/sub.txt",
    "proxies/v2ray.txt",
    "proxies/protocols/http/data.json",
    "proxies/protocols/http/data.txt",
    "proxies/protocols/http/data.csv",
    "proxies/protocols/https/data.json",
    "proxies/protocols/https/data.txt",
    "proxies/protocols/https/data.csv",
    "proxies/protocols/socks5/data.json",
    "proxies/protocols/socks5/data.txt",
    "proxies/protocols/socks5/data.csv",
    "proxies/all/data.json",
    "proxies/all/data.txt",
    "proxies/all/data.csv",
    "protocols/http.txt",
    "protocols/https.txt",
    "protocols/socks5.txt",
    "protocols/http.csv",
    "protocols/https.csv",
    "protocols/socks5.csv",
    "online-proxies/txt/proxies.txt",
    "online-proxies/txt/proxies-http.txt",
    "online-proxies/txt/proxies-https.txt",
    "online-proxies/txt/proxies-socks5.txt",
    "online-proxies/csv/proxies.csv",
    "online-proxies/json/proxies.json",
    "online-proxies/json/proxies-basic.json",
    "online-proxies/yaml/proxies.yaml",
    "online-proxies/yaml/proxies-basic.yaml",
    "online-proxies/xml/proxies.xml",
    "online-proxies/xml/proxies-basic.xml",
    "subs/merged/tested_within.yaml",
    "subs/merged/tested_within_sudoku.yaml",
    "clash/clash.yaml",
    "clash/proxies.yaml",
    "clash/all.yaml",
    "mihomo/mihomo.yaml",
    "mihomo/all.yaml",
    "mihomo/proxies.yaml",
    "mihomo/proxies.yml",
    "mihomo/config.yaml",
    "mihomo/config.yml",
    "mihomo/sub.yaml",
    "mihomo/sub.yml",
    "meta/clash.yaml",
    "meta/mihomo.yaml",
    "meta/proxies.yaml",
    "meta/sub.yaml",
    "config/clash.yaml",
    "config/mihomo.yaml",
    "config/proxies.yaml",
    "config/sub.yaml",
    "configs/clash.yaml",
    "configs/mihomo.yaml",
    "configs/proxies.yaml",
    "configs/sub.yaml",
    "data/clash.yaml",
    "data/mihomo.yaml",
    "data/proxies.yaml",
    "data/sub.yaml",
    "share/clash.yaml",
    "share/mihomo.yaml",
    "share/proxies.yaml",
    "share/sub.yaml",
    "v2ray/v2ray.txt",
    "v2ray/sub.txt",
    "base64/base64.txt",
    "base64/sub.txt",
    "yaml/clash.yaml",
    "yaml/mihomo.yaml",
    "yaml/proxies.yaml",
    "list.txt",
    "links.txt",
    "urls.txt",
    "README.md",
];
const PROXY_URI_SCHEMES: [&[u8]; 25] = [
    b"wireguard",
    b"wg",
    b"trusttunnel",
    b"hysteria1",
    b"hysteria2",
    b"hysteria",
    b"trojan",
    b"vless",
    b"vmess",
    b"anytls",
    b"masque",
    b"mierus",
    b"mieru",
    b"tuic",
    b"snell",
    b"socks5h",
    b"socks5",
    b"socks",
    b"ssh",
    b"https",
    b"http",
    b"ssr",
    b"hy",
    b"hy2",
    b"ss",
];
const EMBEDDED_PROXY_URI_SCHEMES: [&[u8]; 23] = [
    b"wireguard",
    b"wg",
    b"trusttunnel",
    b"hysteria1",
    b"hysteria2",
    b"hysteria",
    b"trojan",
    b"vless",
    b"vmess",
    b"anytls",
    b"masque",
    b"mierus",
    b"mieru",
    b"tuic",
    b"snell",
    b"socks5h",
    b"socks5",
    b"socks",
    b"ssh",
    b"ssr",
    b"hy",
    b"hy2",
    b"ss",
];
const PROXY_URI_SEPARATORS: [&[u8]; 8] = [
    b"://",
    br":\/\/",
    br":\x2f\x2f",
    br":\u002f\u002f",
    b":&#x2f;&#x2f;",
    b":&#47;&#47;",
    b"&colon;&sol;&sol;",
    b"%3a%2f%2f",
];
const PROXY_URI_NAMED_HTML_ENTITIES: [(&[u8], char); 7] = [
    (b"&amp;", '&'),
    (b"&colon;", ':'),
    (b"&sol;", '/'),
    (b"&quest;", '?'),
    (b"&equals;", '='),
    (b"&num;", '#'),
    (b"&commat;", '@'),
];
const PROXY_FINGERPRINT_KEYS: [&str; 7] = [
    "type", "server", "port", "uuid", "password", "cipher", "sni",
];
const SUBSCRIPTION_URL_PARAM_KEYS: [&str; 26] = [
    "subscription=",
    "subscription_url=",
    "subscription-url=",
    "subscriptionUrl=",
    "subscribe=",
    "subscribe_url=",
    "subscribe-url=",
    "subscribeUrl=",
    "profile_url=",
    "profile-url=",
    "profileUrl=",
    "profile=",
    "suburl=",
    "sub_url=",
    "sub-url=",
    "subUrl=",
    "clash_url=",
    "clash-url=",
    "clashUrl=",
    "clash=",
    "v2ray_url=",
    "v2ray-url=",
    "v2rayUrl=",
    "v2ray=",
    "url=",
    "sub=",
];
const SUBSCRIPTION_VALUE_QUERY_KEYS: [&str; 24] = [
    "target",
    "type",
    "format",
    "token",
    "key",
    "uuid",
    "id",
    "password",
    "pwd",
    "server",
    "host",
    "port",
    "path",
    "sni",
    "peer",
    "security",
    "flow",
    "mode",
    "plugin",
    "obfs",
    "allowinsecure",
    "tls",
    "clash",
    "v2ray",
];
const GITHUB_DISCOVERY_INITIAL_CANDIDATE_ESTIMATE: usize = GITHUB_RAW_SEED_PATHS.len() * 3 + 8;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct FreeNodesInput {
    catalog: CatalogInput,
    enabled_source_ids: Vec<String>,
    source_ids: Option<Vec<String>>,
    existing_config_text: Option<String>,
    preference: PreferenceInput,
    fetch_timeout_seconds_by_source: HashMap<String, u64>,
    default_fetch_timeout_seconds: u64,
    proxy_url: Option<String>,
    user_agent: String,
    today_label: String,
    today_token: i64,
    now_day_number: i64,
    now_iso: String,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct CatalogInput {
    history_timeout_hours: i64,
    sources: Vec<SourceInput>,
}

#[derive(Debug, Clone, Deserialize)]
#[serde(rename_all = "camelCase")]
struct SourceInput {
    id: String,
    label: String,
    seed: String,
    rank: i64,
    update_interval_hours: i64,
    page_discovery: bool,
    github_discovery: bool,
    raw_candidates: Vec<String>,
    candidate_urls: Vec<String>,
}

#[derive(Debug, Clone)]
struct CandidateSource {
    id: String,
    label: String,
    seed: String,
    rank: i64,
    update_interval_hours: i64,
    page_discovery: bool,
}

impl CandidateSource {
    fn from_source(source: &SourceInput) -> Self {
        Self {
            id: source.id.clone(),
            label: source.label.clone(),
            seed: source.seed.clone(),
            rank: source.rank,
            update_interval_hours: source.update_interval_hours,
            page_discovery: source.page_discovery,
        }
    }
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct PreferenceInput {
    fetch_concurrency: usize,
    auto_prefer: bool,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct PreferConfigInput {
    config_text: String,
    history_timeout_hours: i64,
    now_day_number: i64,
    today_token: i64,
    delete_expired_groups: bool,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct PreferConfigOutput {
    yaml: String,
    before_count: usize,
    after_count: usize,
    removed_count: usize,
}

#[derive(Debug, Clone)]
struct ConfigCandidate {
    url: String,
    fetch_key: String,
    github_mirrorable: bool,
    date_token: i32,
    source: Arc<CandidateSource>,
}

impl ConfigCandidate {
    fn new(url: String, source: Arc<CandidateSource>) -> Self {
        let fetch_key = canonical_fetch_key(&url);
        let github_mirrorable = is_github_mirrorable_url(&fetch_key);
        let sort_date_token = date_token(&url) as i32;
        Self {
            url,
            fetch_key,
            github_mirrorable,
            date_token: sort_date_token,
            source,
        }
    }

    #[cfg(test)]
    fn from_source_ref(url: String, source: &SourceInput) -> Self {
        Self::new(url, Arc::new(CandidateSource::from_source(source)))
    }

    fn from_candidate_source_ref(url: String, source: &Arc<CandidateSource>) -> Self {
        Self::new(url, Arc::clone(source))
    }
}

#[derive(Debug, Clone)]
struct DatedProxy {
    proxy: Map<String, Value>,
    date_label: String,
    date_token: i64,
    source_id: Option<String>,
    source_label: Option<String>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum ExistingProxyGroup {
    Date(i64),
    Treasure,
}

struct DiscoveryState {
    configs: HashMap<String, Arc<CandidateSource>>,
    page_queue: VecDeque<ConfigCandidate>,
    visited_pages: HashSet<String>,
    visited_page_fetch_keys: HashSet<String>,
    crawled: usize,
}

#[derive(Debug, Default)]
#[frb(ignore)]
struct UriDedupSet {
    buckets: HashMap<DiscoveredUrlFingerprint, DiscoveredUrlBucket>,
}

impl UriDedupSet {
    fn new() -> Self {
        Self::default()
    }

    fn insert(&mut self, values: &[String], value: &str) -> bool {
        self.insert_with_fingerprint(values, value, discovered_url_fingerprint(value))
    }

    fn insert_with_fingerprint(
        &mut self,
        values: &[String],
        value: &str,
        fingerprint: DiscoveredUrlFingerprint,
    ) -> bool {
        let next_index = values.len();
        match self.buckets.get_mut(&fingerprint) {
            Some(DiscoveredUrlBucket::One(index)) => {
                if values.get(*index).is_some_and(|item| item == value) {
                    false
                } else {
                    let first_index = *index;
                    self.buckets.insert(
                        fingerprint,
                        DiscoveredUrlBucket::Many(vec![first_index, next_index]),
                    );
                    true
                }
            }
            Some(DiscoveredUrlBucket::Many(indices)) => {
                if indices
                    .iter()
                    .any(|index| values.get(*index).is_some_and(|item| item == value))
                {
                    false
                } else {
                    indices.push(next_index);
                    true
                }
            }
            None => {
                self.buckets
                    .insert(fingerprint, DiscoveredUrlBucket::One(next_index));
                true
            }
        }
    }
}

struct FetchQueueState {
    queue: VecDeque<ConfigCandidate>,
    in_flight: HashSet<String>,
    successful: HashSet<String>,
}

type SharedFetchQueue = Arc<(Mutex<FetchQueueState>, Condvar)>;
type SharedSourceDeadlines = Arc<Mutex<HashMap<String, Instant>>>;

impl FetchQueueState {
    fn new(candidates: Vec<ConfigCandidate>) -> Self {
        let candidate_count = candidates.len();
        Self {
            queue: VecDeque::from(candidates),
            in_flight: HashSet::with_capacity(candidate_count),
            successful: HashSet::with_capacity(candidate_count),
        }
    }
}

enum FetchQueueAction {
    Fetch {
        candidate: ConfigCandidate,
        fetch_key: String,
    },
    Skip(ConfigCandidate),
    Wait,
    Done,
}

#[derive(Default)]
#[frb(ignore)]
struct AgentCache {
    agents: HashMap<u64, Agent>,
}

impl AgentCache {
    fn get(&mut self, timeout_seconds: u64, proxy_url: Option<&str>) -> Result<Agent, String> {
        if let std::collections::hash_map::Entry::Vacant(entry) = self.agents.entry(timeout_seconds)
        {
            let agent = build_agent(timeout_seconds, proxy_url)?;
            entry.insert(agent);
        }
        self.agents
            .get(&timeout_seconds)
            .cloned()
            .ok_or_else(|| format!("agent cache missing timeout {timeout_seconds}"))
    }

    #[cfg(test)]
    fn len(&self) -> usize {
        self.agents.len()
    }
}

#[derive(Debug, Clone, Serialize)]
#[serde(rename_all = "camelCase")]
struct SourceStatus {
    url: String,
    success: bool,
    proxy_count: usize,
    source_id: String,
    source_label: String,
    update_interval_hours: i64,
    fetched_at: String,
    message: Option<String>,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct FreeNodesOutput {
    yaml: String,
    proxy_count: usize,
    #[serde(skip_serializing_if = "Option::is_none")]
    fresh_proxies: Option<Vec<Map<String, Value>>>,
    sources: Vec<SourceStatus>,
    fetch_times: HashMap<String, String>,
    candidate_count: usize,
    success_source_count: usize,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct FreeNodeSourceStreamEvent {
    kind: &'static str,
    source_id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    output: Option<FreeNodesOutput>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<String>,
}

#[derive(Debug, Clone)]
struct BatchDatedProxy {
    proxy: Map<String, Value>,
    date_label: String,
    date_token: i64,
    source_ids: Vec<String>,
    source_labels: Vec<String>,
}

#[derive(Debug, Default, Clone)]
struct BatchProxyAccumulator {
    indexes: HashMap<String, usize>,
    proxies: Vec<BatchDatedProxy>,
}

impl BatchProxyAccumulator {
    fn add_source_proxies(
        &mut self,
        source: &SourceInput,
        proxies: Vec<Map<String, Value>>,
        date_label: &str,
        date_token: i64,
    ) {
        for proxy in proxies {
            self.add_proxy(
                proxy,
                date_label.to_string(),
                date_token,
                source.id.clone(),
                source.label.clone(),
            );
        }
    }

    fn add_existing_proxy(&mut self, dated: DatedProxy) {
        self.add_proxy(
            dated.proxy,
            dated.date_label,
            dated.date_token,
            dated.source_id.unwrap_or_default(),
            dated.source_label.unwrap_or_default(),
        );
    }

    fn add_proxy(
        &mut self,
        proxy: Map<String, Value>,
        date_label: String,
        date_token: i64,
        source_id: String,
        source_label: String,
    ) {
        let key = proxy_fingerprint(&proxy);
        if let Some(index) = self.indexes.get(&key).copied() {
            if let Some(existing) = self.proxies.get_mut(index) {
                push_unique_non_empty(&mut existing.source_ids, source_id);
                push_unique_non_empty(&mut existing.source_labels, source_label);
            }
            return;
        }

        let index = self.proxies.len();
        self.indexes.insert(key, index);
        let mut source_ids = Vec::with_capacity(1);
        let mut source_labels = Vec::with_capacity(1);
        push_unique_non_empty(&mut source_ids, source_id);
        push_unique_non_empty(&mut source_labels, source_label);
        self.proxies.push(BatchDatedProxy {
            proxy,
            date_label,
            date_token,
            source_ids,
            source_labels,
        });
    }
}

fn push_unique_non_empty(values: &mut Vec<String>, value: String) {
    let value = value.trim();
    if value.is_empty() || values.iter().any(|existing| existing == value) {
        return;
    }
    values.push(value.to_string());
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct StabilitySampleInput {
    proxy_name: String,
    delays: Vec<i64>,
    failures: i64,
}

#[derive(Debug, Serialize)]
#[serde(rename_all = "camelCase")]
struct StabilitySampleOutput {
    proxy_name: String,
    delays: Vec<i64>,
    failures: i64,
    average_delay: Option<i64>,
    variance: f64,
    level: String,
}

#[frb]
pub fn fetch_merge_free_nodes_json(input_json: String) -> Result<String, String> {
    let raw_input: Value =
        serde_json::from_str(&input_json).map_err(|e| format!("free nodes input json: {e}"))?;
    let fresh_proxies_only = raw_input
        .get("freshProxiesOnly")
        .and_then(Value::as_bool)
        .unwrap_or(false);
    let input: FreeNodesInput =
        serde_json::from_value(raw_input).map_err(|e| format!("free nodes input json: {e}"))?;
    let output = fetch_merge_free_nodes_with_mode(input, fresh_proxies_only)?;
    serde_json::to_string(&output).map_err(|e| format!("free nodes output json: {e}"))
}

#[frb]
pub fn stream_fetch_free_node_sources_json(
    input_json: String,
    sink: StreamSink<String, SseCodec>,
) -> Result<(), String> {
    let raw_input: Value =
        serde_json::from_str(&input_json).map_err(|e| format!("free nodes input json: {e}"))?;
    let existing_config_path = raw_input
        .get("existingConfigPath")
        .and_then(Value::as_str)
        .map(str::trim)
        .filter(|value| !value.is_empty())
        .map(str::to_string);
    let mut input: FreeNodesInput =
        serde_json::from_value(raw_input).map_err(|e| format!("free nodes input json: {e}"))?;
    if input.existing_config_text.is_none() {
        if let Some(path) = existing_config_path {
            if let Ok(text) = std::fs::read_to_string(path) {
                input.existing_config_text = Some(text);
            }
        }
    }
    stream_fetch_free_node_sources(input, sink)
}

#[frb]
pub fn prefer_free_nodes_config_json(input_json: String) -> Result<String, String> {
    let input: PreferConfigInput =
        serde_json::from_str(&input_json).map_err(|e| format!("prefer input json: {e}"))?;
    let output = prefer_free_nodes_config(input)?;
    serde_json::to_string(&output).map_err(|e| format!("prefer output json: {e}"))
}

#[frb]
pub fn summarize_free_node_stability_json(input_json: String) -> Result<String, String> {
    let input: StabilitySampleInput =
        serde_json::from_str(&input_json).map_err(|e| format!("stability input json: {e}"))?;
    let output = summarize_free_node_stability(input);
    serde_json::to_string(&output).map_err(|e| format!("stability output json: {e}"))
}

fn summarize_free_node_stability(input: StabilitySampleInput) -> StabilitySampleOutput {
    let delays: Vec<i64> = input
        .delays
        .into_iter()
        .filter(|delay| *delay > 0)
        .collect();
    let failures = input.failures.max(0);
    let stats_delays = stability_stats_delays(&delays);
    let average_delay = if stats_delays.is_empty() {
        None
    } else {
        Some(stats_delays.iter().sum::<i64>() / stats_delays.len() as i64)
    };
    let variance = stability_variance(&stats_delays);
    let level = if delays.len() < 2 || failures > 1 {
        "poor"
    } else if variance <= 2500.0 {
        "good"
    } else if variance <= 10000.0 {
        "normal"
    } else {
        "poor"
    }
    .to_string();
    StabilitySampleOutput {
        proxy_name: input.proxy_name,
        delays,
        failures,
        average_delay,
        variance,
        level,
    }
}

fn stability_stats_delays(values: &[i64]) -> Vec<i64> {
    if values.len() < 3 {
        return values.to_vec();
    }
    let mut values = values.to_vec();
    values.sort_unstable();
    let len = values.len();
    if values[len - 1] > values[len - 2].saturating_mul(3) {
        values.pop();
    }
    values
}

fn stability_variance(values: &[i64]) -> f64 {
    if values.len() <= 1 {
        return 0.0;
    }
    let average = values.iter().sum::<i64>() as f64 / values.len() as f64;
    values
        .iter()
        .map(|value| {
            let diff = *value as f64 - average;
            diff * diff
        })
        .sum::<f64>()
        / values.len() as f64
}

fn fetch_merge_free_nodes(input: FreeNodesInput) -> Result<FreeNodesOutput, String> {
    fetch_merge_free_nodes_with_mode(input, false)
}

fn adaptive_source_worker_count(
    requested_concurrency: usize,
    source_count: usize,
    parallelism: usize,
) -> usize {
    if source_count == 0 {
        return 0;
    }
    let upper_bound = requested_concurrency.clamp(1, source_count);
    let device_parallelism = parallelism.max(1).min(upper_bound);
    let responsive_window = device_parallelism
        .saturating_add(device_parallelism.div_ceil(4))
        .max(1);
    responsive_window.min(upper_bound)
}

fn build_stream_partial_yaml(
    batch: &BatchProxyAccumulator,
    input: &FreeNodesInput,
) -> Result<(String, usize), String> {
    let snapshot = batch.clone();
    let proxy_count = snapshot.proxies.len();
    let yaml = build_batch_clash_yaml(snapshot.proxies, input)?;
    Ok((yaml, proxy_count))
}

fn write_free_nodes_stream_yaml(yaml: String, kind: &str) -> Result<String, String> {
    static FILE_SEQUENCE: AtomicUsize = AtomicUsize::new(0);
    let sequence = FILE_SEQUENCE.fetch_add(1, Ordering::Relaxed);
    let path = std::env::temp_dir().join(format!(
        "flclashplus-free-nodes-{}-{kind}-{sequence}.yaml",
        std::process::id(),
    ));
    std::fs::write(&path, yaml.as_bytes())
        .map_err(|error| format!("free nodes stream temp write: {error}"))?;
    Ok(path.to_string_lossy().into_owned())
}

fn stream_fetch_free_node_sources(
    mut input: FreeNodesInput,
    sink: StreamSink<String, SseCodec>,
) -> Result<(), String> {
    let sources = selected_batch_sources(&input);
    if sources.is_empty() {
        return Ok(());
    }
    let requested_concurrency = input.preference.fetch_concurrency.clamp(1, sources.len());
    let parallelism = thread::available_parallelism()
        .map(|value| value.get())
        .unwrap_or(1);
    let concurrency =
        adaptive_source_worker_count(requested_concurrency, sources.len(), parallelism);
    let queue_capacity = parallelism.min(concurrency).max(1);

    let existing = extract_existing_dated_proxies(
        input.existing_config_text.as_deref(),
        input.catalog.history_timeout_hours,
        input.now_day_number,
        false,
    );
    input.existing_config_text = None;
    let has_existing_config = !existing.is_empty();
    let mut progress_seen = HashSet::<String>::with_capacity(existing.len());
    for dated in &existing {
        progress_seen.insert(proxy_fingerprint(&dated.proxy));
    }
    let started_event = serde_json::to_string(&json!({
        "kind": "started",
        "proxyCount": progress_seen.len(),
        "effectiveConcurrency": concurrency,
        "requestedConcurrency": requested_concurrency,
    }))
    .map_err(|error| format!("free node started stream json: {error}"))?;
    sink.add(started_event)
        .map_err(|error| format!("free node started stream closed: {error}"))?;

    let sources = Arc::new(sources);
    let next_source = AtomicUsize::new(0);
    let (sender, receiver) = mpsc::sync_channel::<FreeNodeSourceStreamEvent>(queue_capacity);

    thread::scope(|scope| -> Result<(), String> {
        for worker_index in 0..concurrency {
            let sender = sender.clone();
            let sources = Arc::clone(&sources);
            let input = &input;
            let next_source = &next_source;
            thread::Builder::new()
                .name(format!("free-node-source-{worker_index}"))
                .stack_size(1024 * 1024)
                .spawn_scoped(scope, move || loop {
                    let index = next_source.fetch_add(1, Ordering::Relaxed);
                    let Some(source) = sources.get(index).cloned() else {
                        break;
                    };
                    let source_id = source.id.clone();
                    let event = match fetch_merge_free_nodes_with_mode(
                        single_source_free_nodes_input(input, source),
                        true,
                    ) {
                        Ok(output) => FreeNodeSourceStreamEvent {
                            kind: "source",
                            source_id,
                            output: Some(output),
                            error: None,
                        },
                        Err(error) => FreeNodeSourceStreamEvent {
                            kind: "source",
                            source_id,
                            output: None,
                            error: Some(error),
                        },
                    };
                    if sender.send(event).is_err() {
                        break;
                    }
                })
                .map_err(|error| format!("free node source worker spawn: {error}"))?;
        }
        drop(sender);

        let sources_by_id = input
            .catalog
            .sources
            .iter()
            .map(|source| (source.id.clone(), source.clone()))
            .collect::<HashMap<_, _>>();
        let mut batch = BatchProxyAccumulator::default();
        let mut completed_sources = 0usize;
        let mut emitted_partial = false;

        for mut event in receiver {
            completed_sources += 1;
            let source = sources_by_id.get(&event.source_id);
            let source_succeeded = event
                .output
                .as_ref()
                .is_some_and(|output| output.success_source_count > 0 && output.proxy_count > 0);
            if let (Some(source), Some(output)) = (source, event.output.as_mut()) {
                if let Some(proxies) = output.fresh_proxies.take() {
                    if source_succeeded {
                        for proxy in &proxies {
                            progress_seen.insert(proxy_fingerprint(proxy));
                        }
                    }
                    batch.add_source_proxies(
                        source,
                        proxies,
                        &input.today_label,
                        input.today_token,
                    );
                }
            }
            let cumulative_proxy_count = progress_seen.len();

            let mut partial_yaml = None::<String>;
            let mut partial_proxy_count = None::<usize>;
            if !has_existing_config
                && source_succeeded
                && completed_sources < sources.len()
                && !emitted_partial
            {
                let (yaml, count) = build_stream_partial_yaml(&batch, &input)?;
                emitted_partial = true;
                partial_yaml = Some(yaml);
                partial_proxy_count = Some(count);
            }

            let encoded = serde_json::to_string(&json!({
                "kind": event.kind,
                "sourceId": event.source_id,
                "output": event.output,
                "error": event.error,
                "cumulativeProxyCount": cumulative_proxy_count,
            }))
            .map_err(|error| format!("free node source stream json: {error}"))?;
            sink.add(encoded)
                .map_err(|error| format!("free node source stream closed: {error}"))?;
            if let (Some(yaml), Some(count)) = (partial_yaml, partial_proxy_count) {
                let file_path = write_free_nodes_stream_yaml(yaml, "partial")?;
                let control = serde_json::to_string(&json!({
                    "kind": "partial",
                    "proxyCount": count,
                    "filePath": file_path,
                }))
                .map_err(|error| format!("free node partial control json: {error}"))?;
                sink.add(control)
                    .map_err(|error| format!("free node partial control closed: {error}"))?;
            }
        }

        let has_fresh = !batch.proxies.is_empty();
        for dated in existing {
            if !has_fresh
                || should_keep_existing_proxy(
                    &dated,
                    input.catalog.history_timeout_hours,
                    input.now_day_number,
                )
            {
                batch.add_existing_proxy(dated);
            }
        }
        let proxy_count = batch.proxies.len();
        let yaml = build_batch_clash_yaml(batch.proxies, &input)?;
        let file_path = write_free_nodes_stream_yaml(yaml, "final")?;
        let final_control = serde_json::to_string(&json!({
            "kind": "final",
            "proxyCount": proxy_count,
            "effectiveConcurrency": concurrency,
            "filePath": file_path,
        }))
        .map_err(|error| format!("free node final control json: {error}"))?;
        sink.add(final_control)
            .map_err(|error| format!("free node final control closed: {error}"))?;
        Ok(())
    })
}

fn normalize_batch_source_label(label: &str) -> String {
    label.split_whitespace().collect::<Vec<_>>().join(" ")
}

fn batch_source_group_names(sources: &[SourceInput]) -> HashMap<String, String> {
    let mut label_counts = HashMap::<String, usize>::with_capacity(sources.len());
    for source in sources {
        let label = normalize_batch_source_label(&source.label);
        *label_counts.entry(label).or_insert(0) += 1;
    }
    let mut groups = HashMap::<String, String>::with_capacity(sources.len());
    for source in sources {
        let label = normalize_batch_source_label(&source.label);
        let suffix = if label_counts.get(&label).copied().unwrap_or_default() > 1 {
            format!(" · {}", source.id)
        } else {
            String::new()
        };
        groups.insert(
            source.id.clone(),
            format!("{FREE_NODES_SOURCE_GROUP_PREFIX}{label}{suffix}"),
        );
    }
    groups
}

fn build_batch_clash_yaml(
    mut proxies: Vec<BatchDatedProxy>,
    input: &FreeNodesInput,
) -> Result<String, String> {
    let candidate_count = proxies.len();
    let mut used_names = HashSet::<String>::with_capacity(candidate_count);
    let mut next_name_suffixes = HashMap::<String, usize>::with_capacity(candidate_count);
    for item in &mut proxies {
        let name = item
            .proxy
            .get("name")
            .and_then(scalar_text_value)
            .filter(|value| !value.trim().is_empty())
            .unwrap_or_else(|| {
                let proxy_type = item.proxy.get("type").and_then(scalar_text_value);
                let server = item.proxy.get("server").and_then(scalar_text_value);
                Cow::Owned(format!(
                    "{}-{}",
                    proxy_type.as_deref().unwrap_or_default(),
                    server.as_deref().unwrap_or_default()
                ))
            });
        let name = unique_name(name.as_ref(), &mut used_names, &mut next_name_suffixes);
        item.proxy.insert("name".into(), json!(name));
        item.date_label = normalize_date_group_label(&item.date_label);
    }

    let source_groups_by_id = batch_source_group_names(&input.catalog.sources);
    let mut source_labels_by_id =
        HashMap::<String, String>::with_capacity(input.catalog.sources.len());
    for source in &input.catalog.sources {
        source_labels_by_id.insert(
            source.id.clone(),
            normalize_batch_source_label(&source.label),
        );
    }
    let mut date_proxy_names = HashMap::<i64, Vec<String>>::new();
    let mut source_proxy_names = HashMap::<String, Vec<String>>::new();
    let mut treasure_proxy_names = Vec::<String>::new();

    for item in &proxies {
        let Some(name) = item.proxy.get("name").and_then(string_value) else {
            continue;
        };
        if is_free_nodes_treasure_group(&item.date_label) {
            treasure_proxy_names.push(name.clone());
        } else if item.date_token > 0 {
            date_proxy_names
                .entry(item.date_token)
                .or_default()
                .push(name.clone());
        }

        let mut covered_labels = HashSet::<String>::with_capacity(item.source_ids.len());
        for source_id in &item.source_ids {
            if let Some(label) = source_labels_by_id.get(source_id) {
                covered_labels.insert(label.clone());
            }
            let group_name = source_groups_by_id
                .get(source_id)
                .cloned()
                .unwrap_or_else(|| format!("{FREE_NODES_SOURCE_GROUP_PREFIX}{source_id}"));
            source_proxy_names
                .entry(group_name)
                .or_default()
                .push(name.clone());
        }
        for source_label in &item.source_labels {
            let label = normalize_batch_source_label(source_label);
            if label.is_empty() || covered_labels.contains(&label) {
                continue;
            }
            source_proxy_names
                .entry(format!("{FREE_NODES_SOURCE_GROUP_PREFIX}{label}"))
                .or_default()
                .push(name.clone());
        }
    }

    let mut date_keys = date_proxy_names.keys().copied().collect::<Vec<_>>();
    date_keys.sort_unstable_by(|a, b| b.cmp(a));
    if input.today_token > 0 {
        if let Some(position) = date_keys
            .iter()
            .position(|value| *value == input.today_token)
        {
            date_keys.rotate_left(position);
        }
    }
    let mut source_group_names = source_proxy_names.keys().cloned().collect::<Vec<_>>();
    source_group_names.sort_unstable();
    let has_treasure = !treasure_proxy_names.is_empty();

    let mut groups = Vec::<Value>::with_capacity(
        2 + date_keys.len() + source_group_names.len() + usize::from(has_treasure),
    );
    let mut main_group = Map::<String, Value>::new();
    main_group.insert("name".into(), json!(FREE_NODES_GROUP_NAME));
    main_group.insert("type".into(), json!("url-test"));
    main_group.insert("hidden".into(), json!(true));
    if input.preference.auto_prefer && (!date_keys.is_empty() || has_treasure) {
        let mut names = date_keys
            .iter()
            .map(|value| date_label_from_token(*value))
            .collect::<Vec<_>>();
        if has_treasure {
            names.push(FREE_NODES_TREASURE_GROUP_NAME.to_string());
        }
        main_group.insert("proxies".into(), json!(names));
    } else if input.preference.auto_prefer && !source_group_names.is_empty() {
        main_group.insert("proxies".into(), json!(source_group_names.clone()));
    } else {
        main_group.insert("include-all-proxies".into(), json!(true));
    }
    main_group.insert("url".into(), json!(DEFAULT_TEST_URL));
    main_group.insert("interval".into(), json!(300));
    main_group.insert("timeout".into(), json!(5000));
    main_group.insert("lazy".into(), json!(true));
    groups.push(Value::Object(main_group));

    if has_treasure {
        groups.push(json!({
            "name": FREE_NODES_TREASURE_GROUP_NAME,
            "type": "url-test",
            "hidden": false,
            "proxies": treasure_proxy_names,
            "url": DEFAULT_TEST_URL,
            "interval": 300,
            "timeout": 5000,
            "lazy": true,
        }));
    }
    for value in &date_keys {
        let label = date_label_from_token(*value);
        let names = date_proxy_names.remove(value).unwrap_or_default();
        groups.push(json!({
            "name": label,
            "type": "url-test",
            "hidden": true,
            "proxies": names,
            "url": DEFAULT_TEST_URL,
            "interval": 300,
            "timeout": 5000,
            "lazy": true,
        }));
    }
    for group_name in &source_group_names {
        let names = source_proxy_names.remove(group_name).unwrap_or_default();
        groups.push(json!({
            "name": group_name,
            "type": "url-test",
            "hidden": false,
            "proxies": names,
            "url": DEFAULT_TEST_URL,
            "interval": 300,
            "timeout": 5000,
            "lazy": true,
        }));
    }

    let mut global_group_names = Vec::<String>::with_capacity(
        date_keys.len() + source_group_names.len() + 3 + usize::from(has_treasure),
    );
    global_group_names.push(FREE_NODES_GROUP_NAME.to_string());
    if has_treasure {
        global_group_names.push(FREE_NODES_TREASURE_GROUP_NAME.to_string());
    }
    global_group_names.extend(date_keys.iter().map(|value| date_label_from_token(*value)));
    global_group_names.extend(source_group_names);
    global_group_names.push("DIRECT".to_string());
    groups.push(json!({
        "name": "GLOBAL",
        "type": "select",
        "hidden": false,
        "proxies": global_group_names,
        "include-all-proxies": true,
    }));

    let normalized_proxies = proxies
        .into_iter()
        .map(|item| Value::Object(item.proxy))
        .collect::<Vec<_>>();
    let value = json!({
        "mixed-port": DEFAULT_MIXED_PORT,
        "allow-lan": false,
        "mode": "rule",
        "log-level": "info",
        "unified-delay": true,
        "proxies": normalized_proxies,
        "proxy-groups": groups,
        "rules": [format!("MATCH,{FREE_NODES_GROUP_NAME}")],
    });
    serde_yaml_ng::to_string(&value).map_err(|error| format!("free nodes batch yaml: {error}"))
}

fn selected_batch_sources(input: &FreeNodesInput) -> Vec<SourceInput> {
    let enabled = input
        .enabled_source_ids
        .iter()
        .map(String::as_str)
        .collect::<HashSet<_>>();
    let targets = input.source_ids.as_ref().map(|source_ids| {
        source_ids
            .iter()
            .map(String::as_str)
            .collect::<HashSet<_>>()
    });
    input
        .catalog
        .sources
        .iter()
        .filter(|source| enabled.contains(source.id.as_str()))
        .filter(|source| {
            targets
                .as_ref()
                .is_none_or(|targets| targets.contains(source.id.as_str()))
        })
        .cloned()
        .collect()
}

fn single_source_free_nodes_input(input: &FreeNodesInput, source: SourceInput) -> FreeNodesInput {
    let source_id = source.id.clone();
    let mut fetch_timeout_seconds_by_source = HashMap::with_capacity(1);
    if let Some(timeout) = input
        .fetch_timeout_seconds_by_source
        .get(&source_id)
        .copied()
    {
        fetch_timeout_seconds_by_source.insert(source_id.clone(), timeout);
    }
    FreeNodesInput {
        catalog: CatalogInput {
            history_timeout_hours: input.catalog.history_timeout_hours,
            sources: vec![source],
        },
        enabled_source_ids: vec![source_id.clone()],
        source_ids: Some(vec![source_id]),
        existing_config_text: None,
        preference: PreferenceInput {
            fetch_concurrency: 1,
            auto_prefer: false,
        },
        fetch_timeout_seconds_by_source,
        default_fetch_timeout_seconds: input.default_fetch_timeout_seconds,
        proxy_url: input.proxy_url.clone(),
        user_agent: input.user_agent.clone(),
        today_label: input.today_label.clone(),
        today_token: input.today_token,
        now_day_number: input.now_day_number,
        now_iso: input.now_iso.clone(),
    }
}

fn fetch_merge_free_nodes_with_mode(
    input: FreeNodesInput,
    fresh_proxies_only: bool,
) -> Result<FreeNodesOutput, String> {
    let source_deadlines = Arc::new(Mutex::new(HashMap::<String, Instant>::new()));
    let candidates = resolve_candidates_with_deadlines(&input, &source_deadlines);
    source_deadlines
        .lock()
        .map_err(|_| "free nodes source deadline lock poisoned".to_string())?
        .clear();
    let candidate_count = candidates.len();
    let concurrency = normalized_free_nodes_fetch_concurrency(
        input.preference.fetch_concurrency,
        candidate_count,
    );
    let shared_input = Arc::new(input);

    let mut fresh_proxies = Vec::<DatedProxy>::with_capacity(candidate_count);
    let mut status_list = Vec::<SourceStatus>::with_capacity(candidate_count);
    if fresh_proxies_only {
        let queue = shared_fetch_queue(candidates);
        let mut agent_cache = AgentCache::default();
        while let Some(action) = next_fetch_action_blocking(&queue) {
            match action {
                FetchQueueAction::Fetch {
                    candidate,
                    fetch_key,
                } => {
                    let success = fetch_candidate(
                        &shared_input,
                        candidate,
                        &mut fresh_proxies,
                        &mut status_list,
                        &mut agent_cache,
                        &source_deadlines,
                    );
                    finish_fetch_candidate_and_notify(&queue, fetch_key, success);
                }
                FetchQueueAction::Skip(candidate) => {
                    push_skipped_duplicate_status(&shared_input, &mut status_list, candidate);
                }
                FetchQueueAction::Wait => {}
                FetchQueueAction::Done => break,
            };
        }
    } else {
        let mut handles = Vec::with_capacity(concurrency);
        if concurrency > 0 {
            let queue = shared_fetch_queue(candidates);
            let worker_result_capacity = candidate_count.div_ceil(concurrency);
            for _ in 0..concurrency {
                let queue = Arc::clone(&queue);
                let input = Arc::clone(&shared_input);
                let source_deadlines = Arc::clone(&source_deadlines);
                handles.push(thread::spawn(move || {
                    let mut agent_cache = AgentCache::default();
                    let mut local_proxies =
                        Vec::<DatedProxy>::with_capacity(worker_result_capacity);
                    let mut local_statuses =
                        Vec::<SourceStatus>::with_capacity(worker_result_capacity);
                    while let Some(action) = next_fetch_action_blocking(&queue) {
                        match action {
                            FetchQueueAction::Fetch {
                                candidate,
                                fetch_key,
                            } => {
                                let success = fetch_candidate(
                                    &input,
                                    candidate,
                                    &mut local_proxies,
                                    &mut local_statuses,
                                    &mut agent_cache,
                                    &source_deadlines,
                                );
                                finish_fetch_candidate_and_notify(&queue, fetch_key, success);
                            }
                            FetchQueueAction::Skip(candidate) => {
                                push_skipped_duplicate_status(
                                    &input,
                                    &mut local_statuses,
                                    candidate,
                                );
                            }
                            FetchQueueAction::Wait => {}
                            FetchQueueAction::Done => break,
                        };
                    }
                    (local_proxies, local_statuses)
                }));
            }
        }

        for handle in handles {
            let (mut local_proxies, mut local_statuses) = handle
                .join()
                .map_err(|_| "free nodes worker panicked".to_string())?;
            fresh_proxies.append(&mut local_proxies);
            status_list.append(&mut local_statuses);
        }
    }

    if fresh_proxies_only {
        status_list.sort_by(|a, b| {
            b.success
                .cmp(&a.success)
                .then_with(|| b.proxy_count.cmp(&a.proxy_count))
                .then_with(|| a.source_label.cmp(&b.source_label))
        });
        let mut fetch_times = HashMap::with_capacity(status_list.len());
        for status in &status_list {
            fetch_times.insert(status.source_id.clone(), status.fetched_at.clone());
        }
        let success_source_count = status_list.iter().filter(|status| status.success).count();
        let fresh_proxies = deduplicate_and_name(fresh_proxies);
        let proxy_count = fresh_proxies.len();
        let fresh_proxies = fresh_proxies
            .into_iter()
            .map(|dated| dated.proxy)
            .collect::<Vec<_>>();
        return Ok(FreeNodesOutput {
            yaml: String::new(),
            proxy_count,
            fresh_proxies: Some(fresh_proxies),
            sources: status_list,
            fetch_times,
            candidate_count,
            success_source_count,
        });
    }

    let merged = merge_fresh_and_existing_dated_proxies(&shared_input, fresh_proxies);
    let merged = deduplicate_and_name(merged);
    let yaml = build_clash_yaml(
        &merged,
        shared_input.today_token,
        shared_input.preference.auto_prefer,
    )?;
    status_list.sort_by(|a, b| {
        b.success
            .cmp(&a.success)
            .then_with(|| b.proxy_count.cmp(&a.proxy_count))
            .then_with(|| a.source_label.cmp(&b.source_label))
    });
    let mut fetch_times = HashMap::with_capacity(status_list.len());
    for status in &status_list {
        fetch_times.insert(status.source_id.clone(), status.fetched_at.clone());
    }
    let success_source_count = status_list.iter().filter(|status| status.success).count();
    Ok(FreeNodesOutput {
        yaml,
        proxy_count: merged.len(),
        fresh_proxies: None,
        sources: status_list,
        fetch_times,
        candidate_count,
        success_source_count,
    })
}

fn merge_fresh_and_existing_dated_proxies(
    input: &FreeNodesInput,
    mut fresh_proxies: Vec<DatedProxy>,
) -> Vec<DatedProxy> {
    let mut existing_proxies = extract_existing_dated_proxies(
        input.existing_config_text.as_deref(),
        input.catalog.history_timeout_hours,
        input.now_day_number,
        !fresh_proxies.is_empty(),
    );
    if fresh_proxies.is_empty() {
        return existing_proxies;
    }
    fresh_proxies.append(&mut existing_proxies);
    fresh_proxies
}

fn normalized_free_nodes_fetch_concurrency(requested: usize, candidate_count: usize) -> usize {
    if candidate_count == 0 {
        return 0;
    }
    requested.clamp(1, 32).min(candidate_count)
}

fn prefer_free_nodes_config(input: PreferConfigInput) -> Result<PreferConfigOutput, String> {
    let before_count = count_usable_proxies(&input.config_text);
    let proxies = extract_existing_dated_proxies(
        Some(input.config_text.as_str()),
        input.history_timeout_hours,
        input.now_day_number,
        input.delete_expired_groups,
    );
    let cleaned = deduplicate_and_name(proxies);
    let after_count = cleaned.len();
    if cleaned.is_empty() {
        return Err("优选后没有可用节点，已保留原配置".to_string());
    }
    let yaml = build_clash_yaml(&cleaned, input.today_token, true)?;
    if yaml.trim().is_empty() {
        return Err("优选结果为空，已保留原配置".to_string());
    }
    Ok(PreferConfigOutput {
        yaml,
        before_count,
        after_count,
        removed_count: before_count.saturating_sub(after_count),
    })
}

fn fetch_candidate(
    input: &FreeNodesInput,
    candidate: ConfigCandidate,
    proxies: &mut Vec<DatedProxy>,
    statuses: &mut Vec<SourceStatus>,
    agent_cache: &mut AgentCache,
    source_deadlines: &SharedSourceDeadlines,
) -> bool {
    fetch_candidate_with_fetcher(
        input,
        candidate,
        proxies,
        statuses,
        agent_cache,
        &|input, source, url, _timeout, agent_cache| {
            let timeout = remaining_source_timeout(input, source, source_deadlines)?;
            fetch_text_for_source_with_timeout(input, source, url, timeout, agent_cache)
        },
    )
}

fn fetch_candidate_with_fetcher<F>(
    input: &FreeNodesInput,
    candidate: ConfigCandidate,
    proxies: &mut Vec<DatedProxy>,
    statuses: &mut Vec<SourceStatus>,
    agent_cache: &mut AgentCache,
    fetcher: &F,
) -> bool
where
    F: Fn(&FreeNodesInput, &CandidateSource, &str, u64, &mut AgentCache) -> Result<String, String>,
{
    let fetched_at = input.now_iso.clone();
    let timeout = source_fetch_timeout(input, candidate.source.as_ref());
    match fetcher(
        input,
        candidate.source.as_ref(),
        &candidate.url,
        timeout,
        agent_cache,
    ) {
        Ok(text) => {
            let mut parsed = parse_proxies(&text);
            parsed.extend(fetch_discovered_provider_proxies_with_fetcher(
                input,
                candidate.source.as_ref(),
                &candidate.url,
                &text,
                timeout,
                agent_cache,
                fetcher,
            ));
            let count = parsed.len();
            if count > 0 {
                let label = normalize_date_group_label(&input.today_label);
                let token = input.today_token;
                proxies.extend(parsed.into_iter().map(|proxy| DatedProxy {
                    proxy,
                    date_label: label.clone(),
                    date_token: token,
                    source_id: Some(candidate.source.id.clone()),
                    source_label: Some(candidate.source.label.clone()),
                }));
            }
            push_status(
                statuses,
                SourceStatus {
                    url: candidate.url,
                    success: count > 0,
                    proxy_count: count,
                    source_id: candidate.source.id.clone(),
                    source_label: candidate.source.label.clone(),
                    update_interval_hours: candidate.source.update_interval_hours,
                    fetched_at,
                    message: if count > 0 {
                        None
                    } else {
                        Some("未解析到可用 Clash 节点".to_string())
                    },
                },
            );
            count > 0
        }
        Err(error) => {
            push_status(
                statuses,
                SourceStatus {
                    url: candidate.url,
                    success: false,
                    proxy_count: 0,
                    source_id: candidate.source.id.clone(),
                    source_label: candidate.source.label.clone(),
                    update_interval_hours: candidate.source.update_interval_hours,
                    fetched_at,
                    message: Some(error),
                },
            );
            false
        }
    }
}

fn fetch_discovered_provider_proxies_with_fetcher<F>(
    input: &FreeNodesInput,
    source: &CandidateSource,
    base_url: &str,
    text: &str,
    timeout: u64,
    agent_cache: &mut AgentCache,
    fetcher: &F,
) -> Vec<Map<String, Value>>
where
    F: Fn(&FreeNodesInput, &CandidateSource, &str, u64, &mut AgentCache) -> Result<String, String>,
{
    let provider_urls = provider_followup_urls_with_decoded_candidates(text, base_url);
    if provider_urls.is_empty() {
        return Vec::new();
    }
    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    let mut seen_fetch_keys = HashSet::<String>::with_capacity(PROVIDER_FOLLOWUP_FETCH_LIMIT + 1);
    seen_fetch_keys.insert(canonical_fetch_key(base_url));
    for url in provider_urls {
        if !is_strong_config_candidate(&url) {
            continue;
        }
        let fetch_key = canonical_fetch_key(&url);
        if !seen_fetch_keys.insert(fetch_key) {
            continue;
        }
        if seen_fetch_keys.len() > PROVIDER_FOLLOWUP_FETCH_LIMIT + 1 {
            break;
        }
        let Ok(provider_text) = fetch_provider_followup_text_with_fetcher(
            input,
            source,
            &url,
            timeout,
            agent_cache,
            fetcher,
        ) else {
            continue;
        };
        let parsed_proxies = parse_proxies(&provider_text);
        if parsed_proxies.is_empty() {
            continue;
        }
        match proxies.as_mut() {
            Some(existing) => existing.extend(parsed_proxies),
            None => proxies = Some(parsed_proxies),
        }
    }
    proxies.unwrap_or_default()
}

fn provider_followup_urls_with_decoded_candidates(text: &str, base_url: &str) -> Vec<String> {
    if has_provider_followup_hint(text) {
        return discover_provider_followup_urls(text, base_url);
    }
    if let Some(decoded) = decode_compact_base64_text(text) {
        if let Some(urls) = provider_followup_urls_from_decoded_candidate(&decoded, base_url) {
            return urls;
        }
    }
    provider_followup_urls_from_embedded_base64(text, base_url).unwrap_or_default()
}

fn provider_followup_urls_from_decoded_candidate(
    candidate: &str,
    base_url: &str,
) -> Option<Vec<String>> {
    if !has_provider_followup_hint(candidate) {
        return None;
    }
    let urls = discover_provider_followup_urls(candidate, base_url);
    (!urls.is_empty()).then_some(urls)
}

fn provider_followup_urls_from_embedded_base64(text: &str, base_url: &str) -> Option<Vec<String>> {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    let mut decoded_count = 0;
    let mut decoded_storage = DecodedCandidateStorage::default();
    while cursor < bytes.len() && decoded_count < DECODED_CANDIDATE_LIMIT {
        while cursor < bytes.len() && !is_base64_byte(bytes[cursor]) {
            cursor += 1;
        }
        let start = cursor;
        while cursor < bytes.len() && is_base64_byte(bytes[cursor]) {
            cursor += 1;
        }
        let token = &text[start..cursor];
        if token.len() < EMBEDDED_BASE64_MIN_LEN || token.len() > EMBEDDED_BASE64_MAX_LEN {
            continue;
        }
        let Some(decoded) = decode_base64_text(token) else {
            continue;
        };
        if !decoded_has_proxy_payload_hint(&decoded) {
            continue;
        }
        if let Some(urls) = provider_followup_urls_from_decoded_candidate(&decoded, base_url) {
            return Some(urls);
        }
        if !decoded_storage.insert(text, decoded) {
            continue;
        }
        decoded_count += 1;
    }
    None
}

fn fetch_provider_followup_text_with_fetcher<F>(
    input: &FreeNodesInput,
    source: &CandidateSource,
    url: &str,
    timeout: u64,
    agent_cache: &mut AgentCache,
    fetcher: &F,
) -> Result<String, String>
where
    F: Fn(&FreeNodesInput, &CandidateSource, &str, u64, &mut AgentCache) -> Result<String, String>,
{
    fetch_github_mirrorable_text_with(url, |candidate_url| {
        fetcher(input, source, candidate_url, timeout, agent_cache)
    })
}

fn discover_provider_followup_urls(text: &str, base_url: &str) -> Vec<String> {
    let provider_urls = extract_yaml_proxy_provider_url_values(text);
    let mut result = Vec::<String>::with_capacity(provider_urls.len());
    let mut index = DiscoveredUrlIndex::with_capacity(provider_urls.len());
    let base = Url::parse(base_url).ok();

    for url in provider_urls {
        insert_ordered_discovered_url(&mut result, &mut index, url, base.as_ref());
    }
    if !result.is_empty() {
        return result;
    }
    if has_yaml_url_field_hint(text) {
        add_yaml_config_url_values(text, &mut result, &mut index, base.as_ref());
    }
    if has_subscription_param_hint(text) {
        add_subscription_urls_from_deep_links(text, &mut result, &mut index, base.as_ref());
    }
    if has_discovery_attribute_hint(text) {
        add_attribute_discovered_urls(text, &mut result, &mut index, base.as_ref());
    }
    if has_quoted_literal_hint(text) {
        add_relative_config_string_values(text, &mut result, &mut index, base.as_ref());
    }
    if has_markdown_link_hint(text) {
        add_markdown_config_links(text, &mut result, &mut index, base.as_ref());
    }

    add_absolute_discovered_urls(text, &mut result, &mut index);
    add_base64_discovered_urls(text, &mut result, &mut index, base.as_ref());

    result
}

fn extract_yaml_proxy_provider_url_values(text: &str) -> Vec<String> {
    let Ok(value) = serde_yaml_ng::from_str::<Value>(text) else {
        return Vec::new();
    };
    let Some(object) = value.as_object() else {
        return Vec::new();
    };
    let Some(providers) = first_yaml_key_value(object, &YAML_PROXY_PROVIDER_KEYS) else {
        return Vec::new();
    };
    let provider_count = providers
        .as_object()
        .map(Map::len)
        .or_else(|| providers.as_array().map(Vec::len))
        .unwrap_or(1);
    let mut urls = Vec::with_capacity(provider_count);
    match providers {
        Value::Object(providers) => {
            for provider in providers.values() {
                push_yaml_proxy_provider_url_value(&mut urls, provider);
            }
        }
        Value::Array(providers) => {
            for provider in providers {
                push_yaml_proxy_provider_url_value(&mut urls, provider);
            }
        }
        provider => push_yaml_proxy_provider_url_value(&mut urls, provider),
    }
    urls
}

const YAML_PROXY_PROVIDER_KEYS: [&str; 6] = [
    "proxy-providers",
    "proxy_providers",
    "proxy-provider",
    "proxy_provider",
    "providers",
    "provider",
];

fn first_yaml_key_value<'a>(object: &'a Map<String, Value>, keys: &[&str]) -> Option<&'a Value> {
    for key in keys {
        if let Some(value) = object.get(*key) {
            return Some(value);
        }
    }
    object.iter().find_map(|(candidate, value)| {
        keys.iter()
            .any(|key| candidate.eq_ignore_ascii_case(key))
            .then_some(value)
    })
}

fn push_yaml_proxy_provider_url_value(urls: &mut Vec<String>, provider: &Value) {
    let raw_url = if let Some(provider) = provider.as_object() {
        first_yaml_key_value(provider, &["url"])
            .or_else(|| first_yaml_key_value(provider, &["path"]))
            .and_then(string_value)
    } else {
        string_value(provider)
    };
    let Some(raw_url) = raw_url else {
        return;
    };
    let url = trim_yaml_config_url_value(&raw_url);
    if should_keep_yaml_config_url_value(url) {
        urls.push(url.to_string());
    }
}

const PROVIDER_FOLLOWUP_HINTS: [&str; 6] = [
    "proxy-providers",
    "proxy_providers",
    "proxy-provider",
    "proxy_provider",
    "provider:",
    "providers:",
];

fn has_provider_followup_hint(text: &str) -> bool {
    contains_any_ascii_case_insensitive(text, &PROVIDER_FOLLOWUP_HINTS)
}

fn push_status(statuses: &mut Vec<SourceStatus>, status: SourceStatus) {
    statuses.push(status);
}

fn push_skipped_duplicate_status(
    input: &FreeNodesInput,
    statuses: &mut Vec<SourceStatus>,
    candidate: ConfigCandidate,
) {
    push_status(
        statuses,
        SourceStatus {
            url: candidate.url,
            success: false,
            proxy_count: 0,
            source_id: candidate.source.id.clone(),
            source_label: candidate.source.label.clone(),
            update_interval_hours: candidate.source.update_interval_hours,
            fetched_at: input.now_iso.clone(),
            message: Some("已跳过重复镜像".to_string()),
        },
    );
}

fn shared_fetch_queue(candidates: Vec<ConfigCandidate>) -> SharedFetchQueue {
    Arc::new((Mutex::new(FetchQueueState::new(candidates)), Condvar::new()))
}

fn next_fetch_action_blocking(queue: &SharedFetchQueue) -> Option<FetchQueueAction> {
    let (lock, condvar) = queue.as_ref();
    let mut guard = lock.lock().ok()?;
    loop {
        match next_fetch_action(&mut guard) {
            FetchQueueAction::Wait => {
                guard = condvar.wait(guard).ok()?;
            }
            action => return Some(action),
        }
    }
}

fn finish_fetch_candidate_and_notify(queue: &SharedFetchQueue, fetch_key: String, success: bool) {
    let (lock, condvar) = queue.as_ref();
    if let Ok(mut guard) = lock.lock() {
        finish_fetch_candidate(&mut guard, fetch_key, success);
        condvar.notify_all();
    }
}

fn next_fetch_action(state: &mut FetchQueueState) -> FetchQueueAction {
    if state.queue.is_empty() {
        return FetchQueueAction::Done;
    }
    for index in 0..state.queue.len() {
        let Some(candidate) = state.queue.get(index) else {
            continue;
        };
        let fetch_key = candidate.fetch_key.as_str();
        if state.successful.contains(fetch_key) {
            if let Some(candidate) = state.queue.remove(index) {
                let skipped_fetch_key = candidate.fetch_key.clone();
                state
                    .queue
                    .retain(|queued| queued.fetch_key.as_str() != skipped_fetch_key.as_str());
                return FetchQueueAction::Skip(candidate);
            }
            continue;
        }
        if !state.in_flight.contains(fetch_key) {
            let Some(candidate) = state.queue.remove(index) else {
                continue;
            };
            let fetch_key = candidate.fetch_key.clone();
            state.in_flight.insert(fetch_key.clone());
            return FetchQueueAction::Fetch {
                candidate,
                fetch_key,
            };
        }
    }
    if state.in_flight.is_empty() {
        FetchQueueAction::Done
    } else {
        FetchQueueAction::Wait
    }
}

fn finish_fetch_candidate(state: &mut FetchQueueState, fetch_key: String, success: bool) {
    state.in_flight.remove(&fetch_key);
    if success {
        state.successful.insert(fetch_key);
    }
}

fn resolve_candidates(input: &FreeNodesInput) -> Vec<ConfigCandidate> {
    let source_deadlines = Arc::new(Mutex::new(HashMap::<String, Instant>::new()));
    resolve_candidates_with_deadlines(input, &source_deadlines)
}

fn resolve_candidates_with_deadlines(
    input: &FreeNodesInput,
    source_deadlines: &SharedSourceDeadlines,
) -> Vec<ConfigCandidate> {
    if input.enabled_source_ids.is_empty() || input.source_ids.as_ref().is_some_and(Vec::is_empty) {
        return Vec::new();
    }
    let mut enabled = HashSet::with_capacity(input.enabled_source_ids.len());
    for id in &input.enabled_source_ids {
        enabled.insert(id.as_str());
    }
    let targets: Option<HashSet<&str>> = input.source_ids.as_ref().map(|ids| {
        let mut targets = HashSet::with_capacity(ids.len());
        for id in ids {
            targets.insert(id.as_str());
        }
        targets
    });
    let initial_candidate_capacity =
        resolve_candidate_initial_capacity(&input.catalog.sources, &enabled, targets.as_ref());
    let mut configs =
        HashMap::<String, Arc<CandidateSource>>::with_capacity(initial_candidate_capacity);
    let mut page_queue = VecDeque::<ConfigCandidate>::with_capacity(initial_candidate_capacity);
    let mut visited_pages = HashSet::<String>::with_capacity(initial_candidate_capacity);
    let mut visited_page_fetch_keys = HashSet::<String>::with_capacity(initial_candidate_capacity);

    for source in &input.catalog.sources {
        if !enabled.contains(source.id.as_str()) {
            continue;
        }
        if let Some(targets) = &targets {
            if !targets.contains(source.id.as_str()) {
                continue;
            }
        }
        let candidate_source = Arc::new(CandidateSource::from_source(source));
        let has_explicit_config_candidates = source_has_explicit_config_candidates(source);
        let normalized_seed = normalize_url(&source.seed);
        if !has_explicit_config_candidates || is_strong_config_candidate(&normalized_seed) {
            add_config_or_page(
                &mut configs,
                &mut page_queue,
                &mut visited_pages,
                &mut visited_page_fetch_keys,
                &source.seed,
                &candidate_source,
            );
        }
        for url in source
            .candidate_urls
            .iter()
            .chain(source.raw_candidates.iter())
        {
            add_config_or_page(
                &mut configs,
                &mut page_queue,
                &mut visited_pages,
                &mut visited_page_fetch_keys,
                url,
                &candidate_source,
            );
        }
        let expand_github_seed_candidates = should_expand_github_seed_candidates(source);
        if expand_github_seed_candidates {
            for url in github_raw_seed_candidates(&source.seed) {
                add_config_or_page(
                    &mut configs,
                    &mut page_queue,
                    &mut visited_pages,
                    &mut visited_page_fetch_keys,
                    &url,
                    &candidate_source,
                );
            }
        }
        if source.github_discovery && !has_explicit_config_candidates {
            for url in github_discovery_candidates(&source.seed) {
                let candidate = ConfigCandidate::from_candidate_source_ref(url, &candidate_source);
                if visited_pages.insert(candidate.url.clone())
                    && visited_page_fetch_keys.insert(candidate.fetch_key.clone())
                {
                    page_queue.push_back(candidate);
                }
            }
        }
    }

    let max_pages = discovery_page_limit(configs.len(), &page_queue);
    configs = discover_pages_parallel_with_deadlines(
        input,
        configs,
        page_queue,
        visited_pages,
        max_pages,
        source_deadlines,
    );

    build_config_candidates(configs)
}

fn resolve_candidate_initial_capacity(
    sources: &[SourceInput],
    enabled: &HashSet<&str>,
    targets: Option<&HashSet<&str>>,
) -> usize {
    let mut capacity = 0usize;
    for source in sources {
        if !enabled.contains(source.id.as_str()) {
            continue;
        }
        if let Some(targets) = targets {
            if !targets.contains(source.id.as_str()) {
                continue;
            }
        }
        capacity = capacity.saturating_add(
            1 + source.candidate_urls.len()
                + source.raw_candidates.len()
                + github_seed_candidate_capacity_estimate(source),
        );
        if capacity >= CONFIG_CANDIDATE_LIMIT {
            return CONFIG_CANDIDATE_LIMIT;
        }
    }
    capacity
}

fn github_seed_candidate_capacity_estimate(source: &SourceInput) -> usize {
    if source.github_discovery {
        GITHUB_DISCOVERY_INITIAL_CANDIDATE_ESTIMATE
    } else if should_expand_github_seed_candidates(source) {
        GITHUB_RAW_SEED_PATHS.len() * 3 + 2
    } else {
        0
    }
}

fn source_has_explicit_config_candidates(source: &SourceInput) -> bool {
    source
        .candidate_urls
        .iter()
        .chain(source.raw_candidates.iter())
        .any(|url| {
            let normalized = normalize_url(url);
            !normalized.is_empty()
                && is_strong_config_candidate(&normalized)
                && !is_unsupported_config_candidate_url(&canonical_config_url(&normalized))
        })
}

fn should_expand_github_seed_candidates(source: &SourceInput) -> bool {
    if source_has_explicit_config_candidates(source) {
        return false;
    }
    source.github_discovery
        || (!source.page_discovery
            && !source.raw_candidates.is_empty()
            && source.raw_candidates.len() <= AUTO_GITHUB_SEED_EXPANSION_RAW_CANDIDATE_LIMIT
            && github_seed_parts(&source.seed).is_some())
}

fn build_config_candidates(configs: HashMap<String, Arc<CandidateSource>>) -> Vec<ConfigCandidate> {
    let mut primaries = Vec::<ConfigCandidate>::with_capacity(configs.len());
    for (url, source) in configs {
        primaries.push(ConfigCandidate::new(url, source));
    }
    sort_config_candidates(&mut primaries);
    let mut candidates = Vec::<ConfigCandidate>::with_capacity(CONFIG_CANDIDATE_LIMIT);
    let mut seen_urls =
        CandidateUrlIndex::with_capacity(primaries.len().min(CONFIG_CANDIDATE_LIMIT));
    let mut fetch_key_counts =
        HashMap::<String, usize>::with_capacity(primaries.len().min(CONFIG_CANDIDATE_LIMIT));

    for candidate in &primaries {
        let primary_url = if candidate.github_mirrorable {
            github_raw_mirror_url_from_prefix(GITHUB_RAW_MIRROR_PREFIXES[0], &candidate.fetch_key)
        } else {
            candidate.url.clone()
        };
        push_unique_config_candidate_from_candidate(
            &mut candidates,
            &mut seen_urls,
            &mut fetch_key_counts,
            primary_url,
            candidate,
            1,
        );
        if candidates.len() >= CONFIG_CANDIDATE_LIMIT {
            return candidates;
        }
    }

    let github_path_mirror_suffixes = github_path_mirror_suffixes(&primaries);
    for prefix in GITHUB_PATH_MIRROR_PREFIXES {
        for (candidate_index, path_mirror_suffix) in &github_path_mirror_suffixes {
            let candidate = &primaries[*candidate_index];
            let fallback_url = github_path_mirror_url_from_suffix(prefix, path_mirror_suffix);
            push_unique_config_candidate_from_candidate(
                &mut candidates,
                &mut seen_urls,
                &mut fetch_key_counts,
                fallback_url,
                candidate,
                MAX_EQUIVALENT_FETCH_CANDIDATES,
            );
            if candidates.len() >= CONFIG_CANDIDATE_LIMIT {
                return candidates;
            }
        }
    }
    for prefix in GITHUB_RAW_PATH_MIRROR_PREFIXES {
        for (candidate_index, path_mirror_suffix) in &github_path_mirror_suffixes {
            let Some(fallback_url) =
                github_raw_path_mirror_url_from_path_suffix(prefix, path_mirror_suffix)
            else {
                continue;
            };
            let candidate = &primaries[*candidate_index];
            push_unique_config_candidate_from_candidate(
                &mut candidates,
                &mut seen_urls,
                &mut fetch_key_counts,
                fallback_url,
                candidate,
                MAX_EQUIVALENT_FETCH_CANDIDATES,
            );
            if candidates.len() >= CONFIG_CANDIDATE_LIMIT {
                return candidates;
            }
        }
    }

    for prefix in GITHUB_RAW_MIRROR_PREFIXES.iter().skip(1) {
        for candidate in &primaries {
            if candidate.github_mirrorable {
                let fallback_url = github_raw_mirror_url_from_prefix(prefix, &candidate.fetch_key);
                push_unique_config_candidate_from_candidate(
                    &mut candidates,
                    &mut seen_urls,
                    &mut fetch_key_counts,
                    fallback_url,
                    candidate,
                    MAX_EQUIVALENT_FETCH_CANDIDATES,
                );
                if candidates.len() >= CONFIG_CANDIDATE_LIMIT {
                    return candidates;
                }
            }
        }
    }

    for candidate in &primaries {
        if candidate.github_mirrorable {
            push_unique_config_candidate_from_candidate(
                &mut candidates,
                &mut seen_urls,
                &mut fetch_key_counts,
                candidate.fetch_key.clone(),
                candidate,
                MAX_EQUIVALENT_FETCH_CANDIDATES,
            );
            if candidates.len() >= CONFIG_CANDIDATE_LIMIT {
                return candidates;
            }
        }
    }

    candidates
}

fn github_path_mirror_suffixes(candidates: &[ConfigCandidate]) -> Vec<(usize, String)> {
    let mut suffixes =
        Vec::<(usize, String)>::with_capacity(candidates.len().min(CONFIG_CANDIDATE_LIMIT));
    for (index, candidate) in candidates.iter().enumerate() {
        if !candidate.github_mirrorable {
            continue;
        }
        if let Some(suffix) = github_path_mirror_suffix(&candidate.fetch_key) {
            suffixes.push((index, suffix));
        }
    }
    suffixes
}

fn push_unique_config_candidate_from_candidate(
    candidates: &mut Vec<ConfigCandidate>,
    seen_urls: &mut CandidateUrlIndex,
    fetch_key_counts: &mut HashMap<String, usize>,
    url: String,
    base: &ConfigCandidate,
    max_equivalent_fetch_candidates: usize,
) {
    let equivalent_count = fetch_key_counts
        .get(base.fetch_key.as_str())
        .copied()
        .unwrap_or(0);
    if equivalent_count >= max_equivalent_fetch_candidates
        || !seen_urls.insert(candidates, url.as_str())
    {
        return;
    }
    if let Some(count) = fetch_key_counts.get_mut(base.fetch_key.as_str()) {
        *count += 1;
    } else {
        fetch_key_counts.insert(base.fetch_key.clone(), 1);
    }
    let candidate = ConfigCandidate {
        url,
        fetch_key: base.fetch_key.clone(),
        github_mirrorable: base.github_mirrorable,
        date_token: base.date_token,
        source: Arc::clone(&base.source),
    };
    candidates.push(candidate);
}

#[derive(Debug, Default)]
#[frb(ignore)]
struct CandidateUrlIndex {
    buckets: HashMap<DiscoveredUrlFingerprint, DiscoveredUrlBucket>,
}

impl CandidateUrlIndex {
    fn with_capacity(capacity: usize) -> Self {
        Self {
            buckets: HashMap::with_capacity(capacity),
        }
    }

    #[cfg(test)]
    fn capacity(&self) -> usize {
        self.buckets.capacity()
    }

    fn insert(&mut self, candidates: &[ConfigCandidate], value: &str) -> bool {
        self.insert_with_fingerprint(candidates, value, discovered_url_fingerprint(value))
    }

    fn insert_with_fingerprint(
        &mut self,
        candidates: &[ConfigCandidate],
        value: &str,
        fingerprint: DiscoveredUrlFingerprint,
    ) -> bool {
        let next_index = candidates.len();
        match self.buckets.get_mut(&fingerprint) {
            Some(DiscoveredUrlBucket::One(index)) => {
                if candidates.get(*index).is_some_and(|item| item.url == value) {
                    false
                } else {
                    let first_index = *index;
                    self.buckets.insert(
                        fingerprint,
                        DiscoveredUrlBucket::Many(vec![first_index, next_index]),
                    );
                    true
                }
            }
            Some(DiscoveredUrlBucket::Many(indices)) => {
                if indices
                    .iter()
                    .any(|index| candidates.get(*index).is_some_and(|item| item.url == value))
                {
                    false
                } else {
                    indices.push(next_index);
                    true
                }
            }
            None => {
                self.buckets
                    .insert(fingerprint, DiscoveredUrlBucket::One(next_index));
                true
            }
        }
    }
}

#[cfg(test)]
fn insert_config_candidate_urls_with_forced_fingerprint_for_testing<const N: usize>(
    values: [&str; N],
) -> Vec<String> {
    let source = Arc::new(CandidateSource {
        id: "candidate-index".into(),
        label: "Candidate index".into(),
        seed: "https://example.com/".into(),
        rank: 0,
        update_interval_hours: 24,
        page_discovery: false,
    });
    let mut candidates = Vec::<ConfigCandidate>::new();
    let mut index = CandidateUrlIndex::default();
    let fingerprint = DiscoveredUrlFingerprint { hash: 11, len: 11 };
    for value in values {
        let candidate = ConfigCandidate::from_candidate_source_ref(value.to_string(), &source);
        if index.insert_with_fingerprint(&candidates, candidate.url.as_str(), fingerprint) {
            candidates.push(candidate);
        }
    }
    candidates
        .into_iter()
        .map(|candidate| candidate.url)
        .collect()
}

fn sort_config_candidates(candidates: &mut [ConfigCandidate]) {
    candidates.sort_by(|a, b| {
        b.date_token
            .cmp(&a.date_token)
            .then_with(|| a.source.rank.cmp(&b.source.rank))
            .then_with(|| a.url.cmp(&b.url))
    });
}

fn discovery_page_limit(config_count: usize, page_queue: &VecDeque<ConfigCandidate>) -> usize {
    let base_limit = if config_count >= DISCOVERY_CONFIG_THRESHOLD {
        FAST_DISCOVERY_PAGE_LIMIT
    } else {
        FULL_DISCOVERY_PAGE_LIMIT
    };
    let mut source_ids = HashSet::<&str>::with_capacity(page_queue.len());
    for candidate in page_queue {
        source_ids.insert(candidate.source.id.as_str());
    }
    let source_count = source_ids.len();
    base_limit
        .max(source_count.saturating_mul(MIN_DISCOVERY_PAGES_PER_SOURCE))
        .min(CONFIG_CANDIDATE_LIMIT)
}

fn discover_pages_parallel_with_deadlines(
    input: &FreeNodesInput,
    configs: HashMap<String, Arc<CandidateSource>>,
    page_queue: VecDeque<ConfigCandidate>,
    visited_pages: HashSet<String>,
    max_pages: usize,
    source_deadlines: &SharedSourceDeadlines,
) -> HashMap<String, Arc<CandidateSource>> {
    discover_pages_with_fetcher(
        input,
        configs,
        page_queue,
        visited_pages,
        max_pages,
        &|input, source, url, agent_cache| {
            let timeout = remaining_source_timeout(input, source, source_deadlines)?;
            fetch_text_for_source_with_timeout(input, source, url, timeout, agent_cache)
        },
    )
}

fn discover_pages_with_fetcher<F>(
    input: &FreeNodesInput,
    configs: HashMap<String, Arc<CandidateSource>>,
    page_queue: VecDeque<ConfigCandidate>,
    visited_pages: HashSet<String>,
    max_pages: usize,
    fetcher: &F,
) -> HashMap<String, Arc<CandidateSource>>
where
    F: Fn(&FreeNodesInput, &CandidateSource, &str, &mut AgentCache) -> Result<String, String>
        + Sync,
{
    if max_pages == 0 || page_queue.is_empty() || configs.len() >= CONFIG_CANDIDATE_LIMIT {
        return configs;
    }
    let discovery_concurrency = input
        .preference
        .fetch_concurrency
        .clamp(1, 8)
        .min(max_pages.max(1));
    let (page_queue, visited_pages, visited_page_fetch_keys) =
        deduplicate_discovery_page_queue(page_queue, visited_pages);
    let state = Arc::new(Mutex::new(DiscoveryState {
        configs,
        page_queue,
        visited_pages,
        visited_page_fetch_keys,
        crawled: 0,
    }));

    thread::scope(|scope| {
        for _ in 0..discovery_concurrency {
            let state = Arc::clone(&state);
            scope.spawn(move || {
                let mut agent_cache = AgentCache::default();
                loop {
                    let candidate = {
                        let mut guard = match state.lock() {
                            Ok(guard) => guard,
                            Err(_) => return,
                        };
                        if guard.crawled >= max_pages
                            || guard.configs.len() >= CONFIG_CANDIDATE_LIMIT
                        {
                            return;
                        }
                        match guard.page_queue.pop_front() {
                            Some(candidate) => {
                                guard.crawled += 1;
                                candidate
                            }
                            None => return,
                        }
                    };

                    let Ok(text) = fetch_discovery_page_text_with_fetcher(
                        input,
                        candidate.source.as_ref(),
                        &candidate.url,
                        &mut agent_cache,
                        fetcher,
                    ) else {
                        continue;
                    };
                    let discovered = discover_urls(&text, &candidate.url);
                    if discovered.is_empty() {
                        continue;
                    }
                    let mut guard = match state.lock() {
                        Ok(guard) => guard,
                        Err(_) => return,
                    };
                    let DiscoveryState {
                        configs,
                        page_queue,
                        visited_pages,
                        visited_page_fetch_keys,
                        ..
                    } = &mut *guard;
                    for url in discovered {
                        add_config_or_page(
                            configs,
                            page_queue,
                            visited_pages,
                            visited_page_fetch_keys,
                            &url,
                            &candidate.source,
                        );
                    }
                }
            });
        }
    });

    match Arc::try_unwrap(state) {
        Ok(mutex) => mutex
            .into_inner()
            .map(|state| state.configs)
            .unwrap_or_default(),
        Err(shared) => shared
            .lock()
            .map(|state| state.configs.clone())
            .unwrap_or_default(),
    }
}

fn fetch_discovery_page_text_with_fetcher<F>(
    input: &FreeNodesInput,
    source: &CandidateSource,
    url: &str,
    agent_cache: &mut AgentCache,
    fetcher: &F,
) -> Result<String, String>
where
    F: Fn(&FreeNodesInput, &CandidateSource, &str, &mut AgentCache) -> Result<String, String>,
{
    fetch_github_mirrorable_text_with(url, |candidate_url| {
        fetcher(input, source, candidate_url, agent_cache)
    })
}

fn fetch_github_mirrorable_text_with<F>(url: &str, mut fetch: F) -> Result<String, String>
where
    F: FnMut(&str) -> Result<String, String>,
{
    if !has_github_fetch_key_canonical_hint(url) {
        return fetch(url);
    }
    let fetch_key = canonical_fetch_key(url);
    if has_github_mirrorable_host_hint(&fetch_key) {
        if let Some((first_raw_prefix, remaining_raw_prefixes)) =
            GITHUB_RAW_MIRROR_PREFIXES.split_first()
        {
            let mirror_url = github_raw_mirror_url_from_prefix(first_raw_prefix, &fetch_key);
            if let Ok(text) = fetch(&mirror_url) {
                return Ok(text);
            }
            if let Some(path_mirror_suffix) = github_path_mirror_suffix(&fetch_key) {
                for prefix in GITHUB_PATH_MIRROR_PREFIXES {
                    let mirror_url =
                        github_path_mirror_url_from_suffix(prefix, &path_mirror_suffix);
                    if let Ok(text) = fetch(&mirror_url) {
                        return Ok(text);
                    }
                }
                for prefix in GITHUB_RAW_PATH_MIRROR_PREFIXES {
                    let Some(mirror_url) =
                        github_raw_path_mirror_url_from_path_suffix(prefix, &path_mirror_suffix)
                    else {
                        continue;
                    };
                    if let Ok(text) = fetch(&mirror_url) {
                        return Ok(text);
                    }
                }
            }
            for prefix in remaining_raw_prefixes {
                let mirror_url = github_raw_mirror_url_from_prefix(prefix, &fetch_key);
                if let Ok(text) = fetch(&mirror_url) {
                    return Ok(text);
                }
            }
        }
        fetch(&fetch_key)
    } else {
        fetch(url)
    }
}

fn deduplicate_discovery_page_queue(
    page_queue: VecDeque<ConfigCandidate>,
    mut visited_pages: HashSet<String>,
) -> (VecDeque<ConfigCandidate>, HashSet<String>, HashSet<String>) {
    let mut deduplicated = VecDeque::with_capacity(page_queue.len());
    let mut visited_page_fetch_keys = HashSet::with_capacity(page_queue.len());
    for candidate in page_queue {
        let fetch_key = candidate.fetch_key.clone();
        if !visited_page_fetch_keys.insert(fetch_key) {
            continue;
        }
        visited_pages.insert(candidate.url.clone());
        deduplicated.push_back(candidate);
    }
    (deduplicated, visited_pages, visited_page_fetch_keys)
}

fn add_config_or_page(
    configs: &mut HashMap<String, Arc<CandidateSource>>,
    page_queue: &mut VecDeque<ConfigCandidate>,
    visited_pages: &mut HashSet<String>,
    visited_page_fetch_keys: &mut HashSet<String>,
    url: &str,
    source: &Arc<CandidateSource>,
) {
    let normalized = normalize_url(url);
    if normalized.is_empty() {
        return;
    }
    if is_unsupported_proxy_data_candidate_url(&normalized) {
        return;
    }
    let github_raw_extensionless_discovery_index =
        is_github_raw_extensionless_discovery_index_candidate(&normalized);
    if github_raw_extensionless_discovery_index && !source.page_discovery {
        return;
    }
    if is_github_readme_discovery_page_candidate(&normalized, source.as_ref())
        || (source.page_discovery && github_raw_extensionless_discovery_index)
    {
        let page_url = canonical_page_url(&normalized);
        let candidate = ConfigCandidate::from_candidate_source_ref(page_url, source);
        if visited_pages.insert(candidate.url.clone())
            && visited_page_fetch_keys.insert(candidate.fetch_key.clone())
        {
            page_queue.push_back(candidate);
        }
    } else if is_strong_config_candidate(&normalized) {
        let normalized = canonical_config_url(&normalized);
        if is_unsupported_config_candidate_url(&normalized) {
            return;
        }
        configs
            .entry(normalized)
            .or_insert_with(|| Arc::clone(source));
    } else if source.page_discovery && is_discovery_page_candidate(&normalized, source.as_ref()) {
        let page_url = canonical_page_url(&normalized);
        let candidate = ConfigCandidate::from_candidate_source_ref(page_url, source);
        if visited_pages.insert(candidate.url.clone())
            && visited_page_fetch_keys.insert(candidate.fetch_key.clone())
        {
            page_queue.push_back(candidate);
        }
    }
}

fn is_github_readme_discovery_page_candidate(url: &str, source: &CandidateSource) -> bool {
    if !source.page_discovery && github_seed_parts(&source.seed).is_none() {
        return false;
    }
    let key = canonical_fetch_key(url);
    let Ok(parsed) = Url::parse(&key) else {
        return false;
    };
    if !parsed
        .host_str()
        .is_some_and(|host| host.eq_ignore_ascii_case("raw.githubusercontent.com"))
    {
        return false;
    }
    let Some(path) = parsed
        .path_segments()
        .and_then(github_raw_config_path_from_segments)
    else {
        return false;
    };
    is_github_readme_markdown_path(&path)
}

fn is_github_raw_extensionless_discovery_index_candidate(url: &str) -> bool {
    let key = canonical_fetch_key(url);
    let Ok(parsed) = Url::parse(&key) else {
        return false;
    };
    if !parsed
        .host_str()
        .is_some_and(|host| host.eq_ignore_ascii_case("raw.githubusercontent.com"))
    {
        return false;
    }
    let Some(path) = parsed
        .path_segments()
        .and_then(github_raw_config_path_from_segments)
    else {
        return false;
    };
    let file_name = path.rsplit('/').next().unwrap_or(path.as_str());
    !file_name.contains('.')
        && (contains_ascii_case_insensitive(file_name, "link")
            || contains_ascii_case_insensitive(file_name, "index"))
        && contains_ascii_case_insensitive(file_name, "sub")
}

fn canonical_config_url(url: &str) -> String {
    canonical_fetch_key(url)
}

fn is_unsupported_config_candidate_url(url: &str) -> bool {
    let Ok(parsed) = Url::parse(url) else {
        return false;
    };
    if !parsed
        .host_str()
        .is_some_and(|host| host.eq_ignore_ascii_case("raw.githubusercontent.com"))
    {
        return false;
    }
    let Some(path) = parsed
        .path_segments()
        .and_then(github_raw_config_path_from_segments)
    else {
        return false;
    };
    is_unsupported_github_proxy_data_path(&path)
}

fn is_unsupported_proxy_data_candidate_url(url: &str) -> bool {
    let Ok(parsed) = Url::parse(url) else {
        return false;
    };
    let path = parsed.path().trim_matches('/');
    let file_name = path.rsplit('/').next().unwrap_or(path);
    matches!(file_name, "socks4.csv" | "socks4.txt" | "socks4.json")
        || is_unsupported_github_proxy_data_path(path)
}

fn github_raw_config_path_from_segments<'a>(
    segments: impl Iterator<Item = &'a str>,
) -> Option<String> {
    let mut segments = segments.skip(3);
    let first = segments.next()?;
    let mut path = String::from(first);
    for segment in segments {
        path.push('/');
        path.push_str(segment);
    }
    Some(path)
}

fn canonical_page_url(url: &str) -> String {
    canonical_fetch_key(url)
}

fn fetch_text_for_source_with_timeout(
    input: &FreeNodesInput,
    _source: &CandidateSource,
    url: &str,
    timeout: u64,
    agent_cache: &mut AgentCache,
) -> Result<String, String> {
    if url.contains("freeclash.top") {
        return fetch_freeclash_top(url, timeout, input, agent_cache);
    }
    fetch_text(url, timeout, input, None, agent_cache)
}

fn source_fetch_timeout(input: &FreeNodesInput, source: &CandidateSource) -> u64 {
    input
        .fetch_timeout_seconds_by_source
        .get(&source.id)
        .copied()
        .unwrap_or(input.default_fetch_timeout_seconds)
        .clamp(3, 120)
}

fn remaining_source_timeout(
    input: &FreeNodesInput,
    source: &CandidateSource,
    source_deadlines: &SharedSourceDeadlines,
) -> Result<u64, String> {
    let request_timeout_seconds = source_fetch_timeout(input, source);
    let source_budget_seconds = request_timeout_seconds.saturating_mul(3).clamp(30, 120);
    let started_at = {
        let mut guard = source_deadlines
            .lock()
            .map_err(|_| format!("{} source deadline lock poisoned", source.label))?;
        *guard.entry(source.id.clone()).or_insert_with(Instant::now)
    };
    let limit = Duration::from_secs(source_budget_seconds);
    let elapsed = started_at.elapsed();
    if elapsed >= limit {
        return Err(format!(
            "{} source fetch timed out after {}s",
            source.label, source_budget_seconds
        ));
    }
    Ok(limit
        .saturating_sub(elapsed)
        .as_secs()
        .max(1)
        .min(request_timeout_seconds))
}

fn build_agent(timeout_seconds: u64, proxy_url: Option<&str>) -> Result<Agent, String> {
    let mut builder =
        Agent::config_builder().timeout_global(Some(Duration::from_secs(timeout_seconds)));
    if let Some(proxy_url) = proxy_url {
        if !proxy_url.trim().is_empty() {
            let proxy = Proxy::new(proxy_url).map_err(|e| format!("proxy {proxy_url}: {e}"))?;
            builder = builder.proxy(Some(proxy));
        }
    }
    Ok(builder.build().into())
}

fn fetch_text(
    url: &str,
    timeout_seconds: u64,
    input: &FreeNodesInput,
    cookie: Option<&str>,
    agent_cache: &mut AgentCache,
) -> Result<String, String> {
    let agent = agent_cache.get(timeout_seconds, input.proxy_url.as_deref())?;
    let mut request = agent
        .get(url)
        .header("User-Agent", &input.user_agent)
        .header(
            "Accept",
            "text/plain, text/yaml, application/yaml, text/html, */*",
        );
    if let Some(cookie) = cookie {
        request = request.header("Cookie", cookie);
    }
    let mut response = request.call().map_err(|e| format!("{url}: {e}"))?;
    response
        .body_mut()
        .with_config()
        .limit(FREE_NODES_RESPONSE_BODY_LIMIT_BYTES)
        .lossy_utf8(true)
        .read_to_string()
        .map_err(|e| format!("{url}: {e}"))
}

fn fetch_freeclash_top(
    url: &str,
    timeout_seconds: u64,
    input: &FreeNodesInput,
    agent_cache: &mut AgentCache,
) -> Result<String, String> {
    let verify_url = if url.contains("/v1/sub/") {
        "https://www.freeclash.top/ui/free_clash"
    } else {
        url
    };
    let page = fetch_text(verify_url, timeout_seconds, input, None, agent_cache)?;
    if !page.contains("/ui/free_clash/verify") {
        return Ok(page);
    }
    let Some(answer) = arithmetic_answer(&page) else {
        return Ok(page);
    };
    let agent = agent_cache.get(timeout_seconds, input.proxy_url.as_deref())?;
    let response = agent
        .post("https://www.freeclash.top/ui/free_clash/verify")
        .header("User-Agent", &input.user_agent)
        .send_form([("answer", answer.to_string())]);
    let Ok(response) = response else {
        return Ok(page);
    };
    let cookie_header = cookie_header_from_set_cookie_values(
        response
            .headers()
            .get_all("set-cookie")
            .iter()
            .filter_map(|value| value.to_str().ok()),
    );
    if cookie_header.is_empty() {
        Ok(page)
    } else {
        fetch_text(
            url,
            timeout_seconds,
            input,
            Some(&cookie_header),
            agent_cache,
        )
        .or(Ok(page))
    }
}

fn cookie_header_from_set_cookie_values<'a>(values: impl IntoIterator<Item = &'a str>) -> String {
    let mut header = String::new();
    for value in values {
        let Some(cookie) = value.split(';').next().map(str::trim) else {
            continue;
        };
        if cookie.is_empty() {
            continue;
        }
        if !header.is_empty() {
            header.push_str("; ");
        }
        header.push_str(cookie);
    }
    header
}

fn arithmetic_answer(text: &str) -> Option<i64> {
    let bytes = text.as_bytes();
    for index in 0..bytes.len() {
        if !bytes[index].is_ascii_digit() {
            continue;
        }
        let mut end = index;
        while end < bytes.len() && bytes[end].is_ascii_digit() {
            end += 1;
        }
        let left = text[index..end].parse::<i64>().ok()?;
        let mut cursor = end;
        while cursor < bytes.len() && bytes[cursor].is_ascii_whitespace() {
            cursor += 1;
        }
        if cursor >= bytes.len() || bytes[cursor] != b'+' {
            continue;
        }
        cursor += 1;
        while cursor < bytes.len() && bytes[cursor].is_ascii_whitespace() {
            cursor += 1;
        }
        let start_right = cursor;
        while cursor < bytes.len() && bytes[cursor].is_ascii_digit() {
            cursor += 1;
        }
        if start_right == cursor {
            continue;
        }
        let right = text[start_right..cursor].parse::<i64>().ok()?;
        return Some(left + right);
    }
    None
}

fn parse_proxies(text: &str) -> Vec<Map<String, Value>> {
    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    visit_decoded_candidates(text, |candidate| {
        let candidate = candidate.as_ref();
        let mut parsed_structured = false;
        if has_yaml_proxy_collection_hint(candidate) {
            let parsed = parse_yaml_proxies(candidate);
            parsed_structured = !parsed.is_empty() && is_structured_proxy_collection(candidate);
            append_parsed_proxies(&mut proxies, parsed);
        }
        let mut parsed_uri = false;
        if !parsed_structured && has_proxy_uri_hint(candidate) {
            let parsed = parse_uri_proxies(candidate);
            parsed_uri = !parsed.is_empty();
            append_parsed_proxies(&mut proxies, parsed);
        }
        if !parsed_structured && !parsed_uri {
            append_parsed_proxies(&mut proxies, parse_protocol_ip_port_csv_proxies(candidate));
        }
        if !parsed_structured && !parsed_uri {
            append_parsed_proxies(&mut proxies, parse_protocol_column_csv_proxies(candidate));
        }
        if !parsed_structured && !parsed_uri {
            append_parsed_proxies(&mut proxies, parse_uri_first_column_csv_proxies(candidate));
        }
        if !parsed_structured && !parsed_uri {
            append_parsed_proxies(&mut proxies, parse_xml_proxy_list(candidate));
        }
        if !parsed_structured && !parsed_uri {
            append_parsed_proxies(&mut proxies, parse_php_serialized_proxy_list(candidate));
        }
        if !parsed_structured {
            append_parsed_proxies(&mut proxies, parse_plain_host_port_proxies(candidate));
        }
        if !parsed_structured {
            append_parsed_proxies(
                &mut proxies,
                parse_annotated_host_port_proxy_tokens(candidate),
            );
        }
    });
    proxies.unwrap_or_default()
}

fn is_structured_proxy_collection(text: &str) -> bool {
    let trimmed = text.trim_start();
    trimmed.starts_with('[') || trimmed.starts_with('{') || trimmed.starts_with('-')
}

fn append_parsed_proxies(
    target: &mut Option<Vec<Map<String, Value>>>,
    parsed: Vec<Map<String, Value>>,
) {
    if parsed.is_empty() {
        return;
    }
    match target.as_mut() {
        Some(existing) => existing.extend(parsed),
        None => *target = Some(parsed),
    }
}

fn count_usable_proxies(text: &str) -> usize {
    parse_proxies(text).len()
}

#[derive(Clone, Copy)]
struct ProtocolCsvColumnOrder {
    protocol: usize,
    server: usize,
    port: usize,
}

const PROTOCOL_CSV_HEADER_SCAN_LIMIT: usize = 8;

fn parse_protocol_ip_port_csv_proxies(text: &str) -> Vec<Map<String, Value>> {
    let mut lines = text
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty() && !line.starts_with('#'));
    let Some(header) = lines.next() else {
        return Vec::new();
    };
    let Some(column_order) = protocol_ip_port_csv_column_order(header) else {
        return Vec::new();
    };

    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    for line in lines {
        let Some((protocol, server, port)) = protocol_csv_fields(line, column_order) else {
            return Vec::new();
        };
        let Some(proxy_type) = generic_proxy_list_type(protocol) else {
            if is_unsupported_generic_proxy_list_type(protocol) {
                continue;
            }
            return Vec::new();
        };
        let Some((server, port)) = normalize_csv_proxy_endpoint(server, port) else {
            return Vec::new();
        };
        let mut proxy = Map::new();
        proxy.insert(
            "name".into(),
            json!(format!("{proxy_type}-{server}:{port}")),
        );
        proxy.insert("type".into(), json!(proxy_type));
        proxy.insert("server".into(), json!(server));
        proxy.insert("port".into(), json!(port));
        push_uri_proxy(&mut proxies, proxy);
    }
    proxies.unwrap_or_default()
}

fn protocol_ip_port_csv_column_order(header: &str) -> Option<ProtocolCsvColumnOrder> {
    let mut protocol = None;
    let mut server = None;
    let mut port = None;
    for (index, field) in header
        .split(',')
        .take(PROTOCOL_CSV_HEADER_SCAN_LIMIT)
        .map(str::trim)
        .enumerate()
    {
        if is_protocol_csv_header_field(field) {
            protocol.replace(index).is_none().then_some(())?;
        } else if is_server_csv_header_field(field) {
            server.replace(index).is_none().then_some(())?;
        } else if field.eq_ignore_ascii_case("port") {
            port.replace(index).is_none().then_some(())?;
        }
    }
    Some(ProtocolCsvColumnOrder {
        protocol: protocol?,
        server: server?,
        port: port?,
    })
}

fn is_protocol_csv_header_field(value: &str) -> bool {
    value.eq_ignore_ascii_case("protocol")
        || value.eq_ignore_ascii_case("type")
        || value.eq_ignore_ascii_case("scheme")
        || value.eq_ignore_ascii_case("proxyType")
}

fn is_server_csv_header_field(value: &str) -> bool {
    value.eq_ignore_ascii_case("ip")
        || value.eq_ignore_ascii_case("host")
        || value.eq_ignore_ascii_case("server")
        || value.eq_ignore_ascii_case("address")
        || value.eq_ignore_ascii_case("addr")
}

fn protocol_csv_fields(line: &str, order: ProtocolCsvColumnOrder) -> Option<(&str, &str, &str)> {
    let mut protocol = None;
    let mut server = None;
    let mut port = None;
    for (index, field) in line
        .split(',')
        .take(PROTOCOL_CSV_HEADER_SCAN_LIMIT)
        .map(str::trim)
        .enumerate()
    {
        if index == order.protocol {
            protocol = Some(field);
        } else if index == order.server {
            server = Some(field);
        } else if index == order.port {
            port = Some(field);
        }
    }
    Some((protocol?, server?, port?))
}

fn normalize_csv_proxy_endpoint(server: &str, port: &str) -> Option<(String, i64)> {
    let port = port.parse::<i64>().ok()?;
    let server = server.trim();
    if server.is_empty() || server.contains(char::is_whitespace) {
        return None;
    }
    Some((server.to_string(), port))
}

fn parse_protocol_column_csv_proxies(text: &str) -> Vec<Map<String, Value>> {
    let mut lines = text
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty() && !line.starts_with('#'));
    let Some(header) = lines.next() else {
        return Vec::new();
    };
    let Some(protocols) = protocol_column_csv_header(header) else {
        return Vec::new();
    };

    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    for line in lines {
        let mut fields = line.split(',');
        for proxy_type in &protocols {
            let Some(endpoint) = fields.next().map(str::trim) else {
                break;
            };
            let Some(proxy_type) = proxy_type else {
                continue;
            };
            if endpoint.is_empty() {
                continue;
            }
            let Some((server, port)) = parse_generic_proxy_host_port(Some(endpoint)) else {
                return Vec::new();
            };
            let mut proxy = Map::new();
            proxy.insert(
                "name".into(),
                json!(format!("{proxy_type}-{server}:{port}")),
            );
            proxy.insert("type".into(), json!(*proxy_type));
            proxy.insert("server".into(), json!(server));
            proxy.insert("port".into(), json!(port));
            push_uri_proxy(&mut proxies, proxy);
        }
    }
    proxies.unwrap_or_default()
}

fn protocol_column_csv_header(header: &str) -> Option<Vec<Option<&'static str>>> {
    let mut protocols = Vec::<Option<&'static str>>::new();
    let mut supported = false;
    for field in header.split(',').map(str::trim) {
        let proxy_type = generic_proxy_list_type(field);
        if proxy_type.is_none() && !is_unsupported_generic_proxy_list_type(field) {
            return None;
        }
        supported |= proxy_type.is_some();
        protocols.push(proxy_type);
    }
    supported.then_some(protocols)
}

fn parse_uri_first_column_csv_proxies(text: &str) -> Vec<Map<String, Value>> {
    let mut seen = UriDedupSet::new();
    let mut seen_values = Vec::<String>::new();
    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    for line in text.lines() {
        let line = line.trim();
        if line.is_empty() || line.starts_with('#') {
            continue;
        }
        let Some((first_field, _)) = line.split_once(',') else {
            return Vec::new();
        };
        let value = normalize_proxy_uri_text(first_field.trim());
        if value.is_empty()
            || !proxy_uri_needle_at_with_schemes(value.as_bytes(), 0, &PROXY_URI_SCHEMES)
        {
            return Vec::new();
        }
        if !seen.insert(&seen_values, &value) {
            continue;
        }
        if starts_with_ascii_case_insensitive(&value, "mierus://")
            || starts_with_ascii_case_insensitive(&value, "mieru://")
        {
            let before_len = proxies.as_ref().map(Vec::len).unwrap_or(0);
            append_uri_proxies(
                &mut proxies,
                parse_mierus_proxies(&value)
                    .into_iter()
                    .filter_map(normalize_proxy),
            );
            if proxies.as_ref().map(Vec::len).unwrap_or(0) == before_len {
                return Vec::new();
            }
            seen_values.push(value);
            continue;
        }
        let Some(proxy) = parse_uri_proxy(&value).and_then(normalize_proxy) else {
            return Vec::new();
        };
        push_uri_proxy(&mut proxies, proxy);
        seen_values.push(value);
    }
    proxies.unwrap_or_default()
}

fn parse_xml_proxy_list(text: &str) -> Vec<Map<String, Value>> {
    let trimmed = text.trim_start();
    if !trimmed.starts_with('<') || !contains_ascii_case_insensitive(trimmed, "<item") {
        let mut proxies = Option::<Vec<Map<String, Value>>>::None;
        append_xml_protocol_endpoint_tags(&mut proxies, text);
        return proxies.unwrap_or_default();
    }

    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    append_xml_protocol_endpoint_tags(&mut proxies, text);
    append_xml_item_proxy_records(&mut proxies, text);
    proxies.unwrap_or_default()
}

fn append_xml_protocol_endpoint_tags(target: &mut Option<Vec<Map<String, Value>>>, text: &str) {
    for (tag, proxy_type) in [("http", "http"), ("https", "http"), ("socks5", "socks5")] {
        for_each_simple_xml_tag_value(text, tag, |value| {
            let Some((server, port)) = parse_generic_proxy_host_port(Some(&value)) else {
                return;
            };
            push_xml_proxy(target, proxy_type, server, port);
        });
    }
}

fn append_xml_item_proxy_records(target: &mut Option<Vec<Map<String, Value>>>, text: &str) {
    let mut cursor = 0;
    while let Some(relative_start) = text[cursor..].find("<item") {
        let start = cursor + relative_start;
        let Some(open_end) = text[start..].find('>').map(|offset| start + offset + 1) else {
            break;
        };
        let Some(close_start) = text[open_end..]
            .find("</item>")
            .map(|offset| open_end + offset)
        else {
            break;
        };
        let item = &text[open_end..close_start];
        if let Some(proxy) = xml_item_proxy_record(item) {
            push_uri_proxy(target, proxy);
        }
        cursor = close_start + "</item>".len();
    }
}

fn xml_item_proxy_record(item: &str) -> Option<Map<String, Value>> {
    let server = first_simple_xml_tag_value(item, "ip")
        .or_else(|| first_simple_xml_tag_value(item, "host"))?;
    let port = first_simple_xml_tag_value(item, "port")?
        .parse::<i64>()
        .ok()?;
    if server.is_empty() || !(1..=65_535).contains(&port) {
        return None;
    }
    let proxy_type = first_simple_xml_tag_value(item, "type")
        .and_then(|value| generic_proxy_list_type(&value))
        .or_else(|| xml_item_flag_proxy_type(item))?;
    Some(xml_proxy_map(proxy_type, server, port))
}

fn xml_item_flag_proxy_type(item: &str) -> Option<&'static str> {
    for (tag, proxy_type) in [("socks5", "socks5"), ("http", "http"), ("ssl", "http")] {
        if first_simple_xml_tag_value(item, tag).is_some_and(|value| value == "1") {
            return Some(proxy_type);
        }
    }
    None
}

fn for_each_simple_xml_tag_value(text: &str, tag: &str, mut visit: impl FnMut(String)) {
    let open = format!("<{tag}>");
    let close = format!("</{tag}>");
    let mut cursor = 0;
    while let Some(relative_start) = text[cursor..].find(&open) {
        let value_start = cursor + relative_start + open.len();
        let Some(value_end) = text[value_start..]
            .find(&close)
            .map(|offset| value_start + offset)
        else {
            break;
        };
        let raw = text[value_start..value_end].trim();
        if !raw.is_empty() && !raw.contains('<') && !raw.contains('>') {
            visit(decode_simple_xml_text(raw));
        }
        cursor = value_start;
    }
}

fn first_simple_xml_tag_value(text: &str, tag: &str) -> Option<String> {
    let mut result = None;
    for_each_simple_xml_tag_value(text, tag, |value| {
        if result.is_none() {
            result = Some(value);
        }
    });
    result
}

fn decode_simple_xml_text(value: &str) -> String {
    value
        .replace("&amp;", "&")
        .replace("&lt;", "<")
        .replace("&gt;", ">")
        .replace("&quot;", "\"")
        .replace("&apos;", "'")
}

fn push_xml_proxy(
    target: &mut Option<Vec<Map<String, Value>>>,
    proxy_type: &'static str,
    server: String,
    port: i64,
) {
    push_uri_proxy(target, xml_proxy_map(proxy_type, server, port));
}

fn xml_proxy_map(proxy_type: &'static str, server: String, port: i64) -> Map<String, Value> {
    let mut proxy = Map::new();
    proxy.insert(
        "name".into(),
        json!(format!("{proxy_type}-{server}:{port}")),
    );
    proxy.insert("type".into(), json!(proxy_type));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));
    proxy
}

fn parse_php_serialized_proxy_list(text: &str) -> Vec<Map<String, Value>> {
    let trimmed = text.trim_start();
    if !trimmed.starts_with("a:") || !trimmed.contains("s:2:\"ip\";") {
        return Vec::new();
    }
    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    let mut cursor = 0;
    while let Some(relative_start) = text[cursor..].find(";a:") {
        let start = cursor + relative_start + 1;
        let Some(record) = php_serialized_array_record(text, start) else {
            cursor = start + 2;
            continue;
        };
        if let Some(proxy) = php_serialized_proxy_record(record) {
            push_uri_proxy(&mut proxies, proxy);
        }
        cursor = start + record.len();
    }
    proxies.unwrap_or_default()
}

fn php_serialized_array_record(text: &str, start: usize) -> Option<&str> {
    let rest = text.get(start..)?;
    if !rest.starts_with("a:") {
        return None;
    }
    let open_relative = rest.find(":{")?;
    let open = start + open_relative + 1;
    let bytes = text.as_bytes();
    let mut depth = 0_i32;
    let mut cursor = open;
    while cursor < bytes.len() {
        match bytes[cursor] {
            b'{' => depth += 1,
            b'}' => {
                depth -= 1;
                if depth == 0 {
                    return text.get(open + 1..cursor);
                }
            }
            _ => {}
        }
        cursor += 1;
    }
    None
}

fn php_serialized_proxy_record(record: &str) -> Option<Map<String, Value>> {
    let server = php_serialized_record_value(record, "ip")
        .or_else(|| php_serialized_record_value(record, "host"))?;
    let port = php_serialized_record_value(record, "port")?
        .parse::<i64>()
        .ok()?;
    if server.is_empty() || !(1..=65_535).contains(&port) {
        return None;
    }
    let proxy_type = php_serialized_record_type(record)?;
    Some(xml_proxy_map(proxy_type, server, port))
}

fn php_serialized_record_type(record: &str) -> Option<&'static str> {
    for (key, proxy_type) in [("socks5", "socks5"), ("http", "http"), ("ssl", "http")] {
        if php_serialized_record_value(record, key).is_some_and(|value| value == "1") {
            return Some(proxy_type);
        }
    }
    None
}

fn php_serialized_record_value(record: &str, key: &str) -> Option<String> {
    let marker = format!("s:{}:\"{}\";", key.len(), key);
    let value_start = record.find(&marker)? + marker.len();
    let rest = record.get(value_start..)?;
    if let Some(rest) = rest.strip_prefix("s:") {
        let (_, value) = rest.split_once(":\"")?;
        let end = value.find("\";")?;
        return Some(value[..end].to_string());
    }
    if let Some(rest) = rest.strip_prefix("i:") {
        let end = rest.find(';')?;
        return Some(rest[..end].to_string());
    }
    None
}

struct PlainProxyEndpoint {
    proxy_type: &'static str,
    server: String,
    port: i64,
    username: Option<String>,
    password: Option<String>,
}

fn parse_plain_host_port_proxies(text: &str) -> Vec<Map<String, Value>> {
    let mut endpoints = Option::<Vec<PlainProxyEndpoint>>::None;
    for line in text.lines() {
        let line = strip_plain_proxy_line_comment(line);
        if line.is_empty() {
            continue;
        }
        let Some(endpoint) = parse_plain_proxy_endpoint(line) else {
            if is_plain_unsupported_proxy_endpoint(line) {
                continue;
            }
            return Vec::new();
        };
        match endpoints.as_mut() {
            Some(items) => items.push(endpoint),
            None => endpoints = Some(vec![endpoint]),
        }
    }
    let Some(endpoints) = endpoints else {
        return Vec::new();
    };
    let mut proxies = Vec::<Map<String, Value>>::with_capacity(endpoints.len());
    for endpoint in endpoints {
        let mut proxy = Map::new();
        proxy.insert(
            "name".into(),
            json!(format!(
                "{}-{}:{}",
                endpoint.proxy_type, endpoint.server, endpoint.port
            )),
        );
        proxy.insert("type".into(), json!(endpoint.proxy_type));
        proxy.insert("server".into(), json!(endpoint.server));
        proxy.insert("port".into(), json!(endpoint.port));
        if let Some(username) = endpoint.username {
            proxy.insert("username".into(), json!(username));
        }
        if let Some(password) = endpoint.password {
            proxy.insert("password".into(), json!(password));
        }
        proxies.push(proxy);
    }
    proxies
}

fn parse_plain_proxy_endpoint(value: &str) -> Option<PlainProxyEndpoint> {
    if let Some((user_info, host_port)) = value.rsplit_once('@') {
        let (username, password) = user_info.split_once(':')?;
        if username.is_empty() || password.is_empty() {
            return None;
        }
        let (server, port) = parse_generic_proxy_host_port(Some(host_port))?;
        return Some(PlainProxyEndpoint {
            proxy_type: "http",
            server,
            port,
            username: Some(percent_decode(username)),
            password: Some(percent_decode(password)),
        });
    }
    if let Some((head, password)) = value.rsplit_once(':') {
        if let Some((host_port, username)) = head.rsplit_once(':') {
            if !username.is_empty() && !password.is_empty() {
                if let Some((server, port)) = parse_generic_proxy_host_port(Some(host_port)) {
                    return Some(PlainProxyEndpoint {
                        proxy_type: "http",
                        server,
                        port,
                        username: Some(percent_decode(username)),
                        password: Some(percent_decode(password)),
                    });
                }
            }
        }
    }
    if let Some(endpoint) = parse_plain_protocol_columns_proxy_endpoint(value) {
        return Some(endpoint);
    }
    if let Some(endpoint) = parse_plain_auth_columns_proxy_endpoint(value) {
        return Some(endpoint);
    }
    if let Some((server, port)) = parse_plain_two_column_proxy_endpoint(value) {
        return Some(PlainProxyEndpoint {
            proxy_type: "http",
            server,
            port,
            username: None,
            password: None,
        });
    }
    let (server, port) = parse_generic_proxy_host_port(Some(value))?;
    Some(PlainProxyEndpoint {
        proxy_type: "http",
        server,
        port,
        username: None,
        password: None,
    })
}

fn is_plain_unsupported_proxy_endpoint(value: &str) -> bool {
    for delimiter in [',', ';', '|'] {
        if is_plain_unsupported_delimited_proxy_endpoint(value, delimiter) {
            return true;
        }
    }
    let mut fields = value.split_whitespace();
    let first = fields.next();
    let second = fields.next();
    let third = fields.next();
    let fourth = fields.next();
    let fifth = fields.next();
    if fields.next().is_some() {
        return false;
    }
    is_plain_unsupported_proxy_fields(first, second, third, fourth, fifth)
}

fn is_plain_unsupported_delimited_proxy_endpoint(value: &str, delimiter: char) -> bool {
    let mut fields = value.split(delimiter).map(str::trim);
    let first = fields.next();
    let second = fields.next();
    let third = fields.next();
    let fourth = fields.next();
    let fifth = fields.next();
    if fields.next().is_some() {
        return false;
    }
    is_plain_unsupported_proxy_fields(first, second, third, fourth, fifth)
}

fn is_plain_unsupported_proxy_fields(
    first: Option<&str>,
    second: Option<&str>,
    third: Option<&str>,
    fourth: Option<&str>,
    fifth: Option<&str>,
) -> bool {
    let Some(first) = first else {
        return false;
    };
    let Some(second) = second else {
        return false;
    };
    let Some(third) = third else {
        return false;
    };
    let protocol_first = is_unsupported_generic_proxy_list_type(first)
        && normalize_csv_proxy_endpoint(second, third).is_some();
    if protocol_first {
        return true;
    }
    if is_unsupported_generic_proxy_list_type(third)
        && normalize_csv_proxy_endpoint(first, second).is_some()
    {
        return true;
    }
    fifth.is_some_and(is_unsupported_generic_proxy_list_type)
        && normalize_csv_proxy_endpoint(first, second).is_some()
        && fourth.is_some_and(|username| !username.is_empty())
}

fn parse_plain_auth_columns_proxy_endpoint(value: &str) -> Option<PlainProxyEndpoint> {
    for delimiter in [',', ';', '|'] {
        if let Some(endpoint) = parse_plain_auth_delimited_proxy_endpoint(value, delimiter) {
            return Some(endpoint);
        }
    }
    let mut fields = value.split_whitespace();
    let server = fields.next()?;
    let port = fields.next()?;
    let username = fields.next()?;
    let password = fields.next()?;
    if fields.next().is_some() {
        return None;
    }
    parse_plain_auth_proxy_fields(server, port, username, password)
}

fn parse_plain_auth_delimited_proxy_endpoint(
    value: &str,
    delimiter: char,
) -> Option<PlainProxyEndpoint> {
    let mut fields = value.split(delimiter);
    let server = fields.next()?.trim();
    let port = fields.next()?.trim();
    let username = fields.next()?.trim();
    let password = fields.next()?.trim();
    if fields.next().is_some() {
        return None;
    }
    parse_plain_auth_proxy_fields(server, port, username, password)
}

fn parse_plain_auth_proxy_fields(
    server: &str,
    port: &str,
    username: &str,
    password: &str,
) -> Option<PlainProxyEndpoint> {
    if username.is_empty() || password.is_empty() || !is_plain_proxy_auth_host(server) {
        return None;
    }
    let (server, port) = normalize_csv_proxy_endpoint(server, port)?;
    if !(1..=65_535).contains(&port) {
        return None;
    }
    Some(PlainProxyEndpoint {
        proxy_type: "http",
        server,
        port,
        username: Some(percent_decode(username)),
        password: Some(percent_decode(password)),
    })
}

fn is_plain_proxy_auth_host(value: &str) -> bool {
    value.parse::<std::net::Ipv4Addr>().is_ok()
        || value.parse::<std::net::Ipv6Addr>().is_ok()
        || value.contains('.')
}

fn parse_plain_protocol_columns_proxy_endpoint(value: &str) -> Option<PlainProxyEndpoint> {
    for delimiter in [',', ';', '|'] {
        if let Some(endpoint) = parse_plain_protocol_delimited_proxy_endpoint(value, delimiter) {
            return Some(endpoint);
        }
    }
    let mut fields = value.split_whitespace();
    let first = fields.next()?;
    let second = fields.next()?;
    let third = fields.next()?;
    let fourth = fields.next();
    let fifth = fields.next();
    if fields.next().is_some() {
        return None;
    }
    parse_plain_protocol_proxy_fields(first, second, third, fourth, fifth)
}

fn parse_plain_protocol_delimited_proxy_endpoint(
    value: &str,
    delimiter: char,
) -> Option<PlainProxyEndpoint> {
    let mut fields = value.split(delimiter);
    let first = fields.next()?.trim();
    let second = fields.next()?.trim();
    let third = fields.next()?.trim();
    let fourth = fields.next().map(str::trim);
    let fifth = fields.next().map(str::trim);
    if fields.next().is_some() {
        return None;
    }
    parse_plain_protocol_proxy_fields(first, second, third, fourth, fifth)
}

fn parse_plain_protocol_proxy_fields(
    first: &str,
    second: &str,
    third: &str,
    fourth: Option<&str>,
    fifth: Option<&str>,
) -> Option<PlainProxyEndpoint> {
    match (fourth, fifth) {
        (None, None) => {}
        (Some(_), None) | (None, Some(_)) => return None,
        (Some(username), Some(password)) => {
            if let Some(proxy_type) = generic_proxy_list_type(first) {
                let (server, port) = normalize_csv_proxy_endpoint(second, third)?;
                return Some(PlainProxyEndpoint {
                    proxy_type,
                    server,
                    port,
                    username: Some(percent_decode(username)),
                    password: Some(percent_decode(password)),
                });
            }
            if let Some(proxy_type) = generic_proxy_list_type(password) {
                let (server, port) = normalize_csv_proxy_endpoint(first, second)?;
                return Some(PlainProxyEndpoint {
                    proxy_type,
                    server,
                    port,
                    username: Some(percent_decode(third)),
                    password: Some(percent_decode(username)),
                });
            }
            return None;
        }
    }
    if let Some(proxy_type) = generic_proxy_list_type(first) {
        let (server, port) = normalize_csv_proxy_endpoint(second, third)?;
        return Some(PlainProxyEndpoint {
            proxy_type,
            server,
            port,
            username: None,
            password: None,
        });
    }
    if let Some(proxy_type) = generic_proxy_list_type(third) {
        let (server, port) = normalize_csv_proxy_endpoint(first, second)?;
        return Some(PlainProxyEndpoint {
            proxy_type,
            server,
            port,
            username: None,
            password: None,
        });
    }
    None
}

fn parse_plain_two_column_proxy_endpoint(value: &str) -> Option<(String, i64)> {
    for delimiter in [',', ';', '|'] {
        if let Some(endpoint) = parse_plain_delimited_proxy_endpoint(value, delimiter) {
            return Some(endpoint);
        }
    }
    let mut fields = value.split_whitespace();
    let server = fields.next()?;
    let port = fields.next()?;
    if fields.next().is_some() {
        return None;
    }
    normalize_csv_proxy_endpoint(server, port)
}

fn parse_plain_delimited_proxy_endpoint(value: &str, delimiter: char) -> Option<(String, i64)> {
    let (server, port) = value.split_once(delimiter)?;
    if port.contains(delimiter) {
        return None;
    }
    normalize_csv_proxy_endpoint(server, port)
}

fn strip_plain_proxy_line_comment(line: &str) -> &str {
    let line = line.trim();
    if line.starts_with('#') {
        return "";
    }
    let comment_start = line
        .match_indices('#')
        .find_map(|(index, _)| {
            (index == 0
                || line
                    .as_bytes()
                    .get(..index)
                    .and_then(|bytes| bytes.last())
                    .is_some_and(u8::is_ascii_whitespace))
            .then_some(index)
        })
        .unwrap_or(line.len());
    line[..comment_start].trim()
}

fn parse_annotated_host_port_proxy_tokens(text: &str) -> Vec<Map<String, Value>> {
    let mut endpoints = Option::<Vec<(String, i64)>>::None;
    let mut first = None;
    let mut second = None;
    for third in text.split_whitespace() {
        let (Some(endpoint), Some(marker)) = (first, second) else {
            first = second;
            second = Some(third);
            continue;
        };
        if !is_proxy_status_token(third) || !is_proxy_country_marker_token(marker) {
            first = second;
            second = Some(third);
            continue;
        }
        let Some((server, port)) = parse_generic_proxy_host_port(Some(endpoint)) else {
            first = second;
            second = Some(third);
            continue;
        };
        if !is_ipv4_proxy_host(&server) || !(1..=65_535).contains(&port) {
            first = second;
            second = Some(third);
            continue;
        }
        match endpoints.as_mut() {
            Some(items) => items.push((server, port)),
            None => endpoints = Some(vec![(server, port)]),
        }
        first = second;
        second = Some(third);
    }
    let Some(endpoints) = endpoints else {
        return Vec::new();
    };
    let mut proxies = Vec::<Map<String, Value>>::with_capacity(endpoints.len());
    for (server, port) in endpoints {
        let mut proxy = Map::new();
        proxy.insert("name".into(), json!(format!("http-{server}:{port}")));
        proxy.insert("type".into(), json!("http"));
        proxy.insert("server".into(), json!(server));
        proxy.insert("port".into(), json!(port));
        proxies.push(proxy);
    }
    proxies
}

fn is_proxy_status_token(value: &str) -> bool {
    matches!(value, "+" | "-" | "–")
}

fn is_proxy_country_marker_token(value: &str) -> bool {
    let Some((country, flags)) = value.split_once('-') else {
        return false;
    };
    country.len() == 2
        && country.bytes().all(|byte| byte.is_ascii_uppercase())
        && !flags.is_empty()
        && flags
            .bytes()
            .all(|byte| byte.is_ascii_uppercase() || matches!(byte, b'-' | b'!'))
}

fn is_ipv4_proxy_host(value: &str) -> bool {
    value.parse::<std::net::Ipv4Addr>().is_ok()
}

#[cfg(test)]
fn decode_candidates(text: &str) -> Vec<Cow<'_, str>> {
    let mut candidates = vec![Cow::Borrowed(text)];
    visit_decoded_candidates(text, |candidate| {
        if let DecodedCandidate::Owned(value) = candidate {
            candidates.push(Cow::Owned(value.to_string()));
        }
    });
    candidates
}

enum DecodedCandidate<'a> {
    Borrowed(&'a str),
    Owned(&'a str),
}

impl DecodedCandidate<'_> {
    fn as_ref(&self) -> &str {
        match self {
            DecodedCandidate::Borrowed(value) => value,
            DecodedCandidate::Owned(value) => value,
        }
    }
}

fn visit_decoded_candidates<F>(text: &str, mut visit: F)
where
    F: FnMut(DecodedCandidate<'_>),
{
    visit(DecodedCandidate::Borrowed(text));

    let mut accepted_decoded = 0_usize;
    let mut decoded_storage = DecodedCandidateStorage::default();
    let mut push_decoded =
        |decoded: String| decoded_storage.push_and_visit(text, decoded, &mut visit);

    if let Some(decoded) = decode_compact_base64_text(text) {
        if push_decoded(decoded) {
            accepted_decoded += 1;
        }
    }
    if accepted_decoded < DECODED_CANDIDATE_LIMIT {
        if let Some(decoded) = decode_decimal_byte_stream_text(text) {
            if push_decoded(decoded) {
                accepted_decoded += 1;
            }
        }
    }
    visit_embedded_base64_candidates(text, &mut accepted_decoded, &mut push_decoded);
}

#[derive(Debug, Default)]
#[frb(ignore)]
struct DecodedCandidateIndex {
    buckets: HashMap<DiscoveredUrlFingerprint, DiscoveredUrlBucket>,
}

impl DecodedCandidateIndex {
    fn with_capacity(capacity: usize) -> Self {
        Self {
            buckets: HashMap::with_capacity(capacity),
        }
    }

    #[cfg(test)]
    fn capacity(&self) -> usize {
        self.buckets.capacity()
    }

    fn insert(&mut self, decoded_values: &[String], original: &str, value: &str) -> bool {
        if value == original {
            return false;
        }
        self.insert_with_fingerprint(decoded_values, value, discovered_url_fingerprint(value))
    }

    fn insert_with_fingerprint(
        &mut self,
        decoded_values: &[String],
        value: &str,
        fingerprint: DiscoveredUrlFingerprint,
    ) -> bool {
        let next_index = decoded_values.len();
        match self.buckets.get_mut(&fingerprint) {
            Some(DiscoveredUrlBucket::One(index)) => {
                if decoded_values.get(*index).is_some_and(|item| item == value) {
                    false
                } else {
                    let first_index = *index;
                    self.buckets.insert(
                        fingerprint,
                        DiscoveredUrlBucket::Many(vec![first_index, next_index]),
                    );
                    true
                }
            }
            Some(DiscoveredUrlBucket::Many(indices)) => {
                if indices
                    .iter()
                    .any(|index| decoded_values.get(*index).is_some_and(|item| item == value))
                {
                    false
                } else {
                    indices.push(next_index);
                    true
                }
            }
            None => {
                self.buckets
                    .insert(fingerprint, DiscoveredUrlBucket::One(next_index));
                true
            }
        }
    }
}

#[derive(Debug, Default)]
#[frb(ignore)]
struct DecodedCandidateStorage {
    values: Option<Vec<String>>,
    index: Option<DecodedCandidateIndex>,
}

impl DecodedCandidateStorage {
    fn insert(&mut self, original: &str, decoded: String) -> bool {
        self.insert_and_visit(original, decoded, |_| {})
    }

    fn insert_and_visit<F>(&mut self, original: &str, decoded: String, visit: F) -> bool
    where
        F: FnOnce(&str),
    {
        let values = self
            .values
            .get_or_insert_with(|| Vec::with_capacity(DECODED_CANDIDATE_LIMIT));
        let index = self
            .index
            .get_or_insert_with(|| DecodedCandidateIndex::with_capacity(DECODED_CANDIDATE_LIMIT));
        if !index.insert(values, original, decoded.as_str()) {
            return false;
        }
        values.push(decoded);
        if let Some(value) = values.last() {
            visit(value.as_str());
        }
        true
    }

    fn push_and_visit<F>(&mut self, original: &str, decoded: String, visit: &mut F) -> bool
    where
        F: FnMut(DecodedCandidate<'_>),
    {
        self.insert_and_visit(original, decoded, |value| {
            visit(DecodedCandidate::Owned(value));
        })
    }
}

#[cfg(test)]
fn insert_decoded_candidates_with_forced_fingerprint_for_testing<const N: usize>(
    values: [&str; N],
) -> Vec<String> {
    let mut decoded_values = Vec::<String>::new();
    let mut index = DecodedCandidateIndex::default();
    let fingerprint = DiscoveredUrlFingerprint { hash: 17, len: 17 };
    for value in values {
        if index.insert_with_fingerprint(&decoded_values, value, fingerprint) {
            decoded_values.push(value.to_string());
        }
    }
    decoded_values
}

fn decode_compact_base64_text(text: &str) -> Option<String> {
    let mut compact_len = 0;
    let mut has_whitespace = false;
    for byte in text.bytes() {
        if byte.is_ascii_whitespace() {
            has_whitespace = true;
            continue;
        }
        if !is_base64_byte(byte) {
            return None;
        }
        compact_len += 1;
    }
    if compact_len < 16 {
        return None;
    }
    if !has_whitespace {
        return decode_base64_text(text);
    }

    let mut compact = String::with_capacity(compact_len);
    for byte in text.bytes() {
        if !byte.is_ascii_whitespace() {
            compact.push(byte as char);
        }
    }
    decode_base64_text(&compact)
}

fn decode_decimal_byte_stream_text(text: &str) -> Option<String> {
    let token_count = count_decimal_byte_stream_tokens(text)?;
    if token_count < DECIMAL_BYTE_STREAM_MIN_TOKENS {
        return None;
    }

    let bytes = text.as_bytes();
    let mut decoded = Vec::with_capacity(token_count);
    let mut cursor = 0;
    while cursor < bytes.len() {
        while cursor < bytes.len() && bytes[cursor].is_ascii_whitespace() {
            cursor += 1;
        }
        if cursor == bytes.len() {
            break;
        }

        let mut value = 0_u16;
        while cursor < bytes.len() && bytes[cursor].is_ascii_digit() {
            value = value * 10 + u16::from(bytes[cursor] - b'0');
            cursor += 1;
        }
        decoded.push(value as u8);
    }

    let decoded = String::from_utf8(decoded).ok()?;
    decoded_has_proxy_payload_hint(&decoded).then_some(decoded)
}

fn count_decimal_byte_stream_tokens(text: &str) -> Option<usize> {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    let mut count = 0_usize;
    while cursor < bytes.len() {
        while cursor < bytes.len() && bytes[cursor].is_ascii_whitespace() {
            cursor += 1;
        }
        if cursor == bytes.len() {
            break;
        }

        let mut value = 0_u16;
        let mut digit_count = 0_u8;
        while cursor < bytes.len() && bytes[cursor].is_ascii_digit() {
            digit_count += 1;
            if digit_count > 3 {
                return None;
            }
            value = value * 10 + u16::from(bytes[cursor] - b'0');
            if value > u16::from(u8::MAX) {
                return None;
            }
            cursor += 1;
        }
        if digit_count == 0 {
            return None;
        }
        if cursor < bytes.len() && !bytes[cursor].is_ascii_whitespace() {
            return None;
        }
        count += 1;
    }
    (count > 0).then_some(count)
}

fn visit_embedded_base64_candidates<F>(
    text: &str,
    accepted_decoded: &mut usize,
    push_decoded: &mut F,
) where
    F: FnMut(String) -> bool,
{
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() && *accepted_decoded + 1 < DECODED_CANDIDATE_LIMIT {
        while cursor < bytes.len() && !is_base64_byte(bytes[cursor]) {
            cursor += 1;
        }
        let start = cursor;
        while cursor < bytes.len() && is_base64_byte(bytes[cursor]) {
            cursor += 1;
        }
        let token = &text[start..cursor];
        if token.len() < EMBEDDED_BASE64_MIN_LEN || token.len() > EMBEDDED_BASE64_MAX_LEN {
            continue;
        }
        if let Some(decoded) = decode_base64_text(token) {
            if decoded_has_proxy_payload_hint(&decoded) && push_decoded(decoded) {
                *accepted_decoded += 1;
            }
        }
    }
}

fn is_base64_byte(byte: u8) -> bool {
    byte.is_ascii_alphanumeric() || matches!(byte, b'+' | b'/' | b'-' | b'_' | b'=')
}

fn decoded_has_proxy_payload_hint(text: &str) -> bool {
    has_non_http_proxy_uri_hint(text)
        || has_yaml_proxy_collection_hint(text)
        || has_provider_followup_hint(text)
}

fn has_yaml_proxy_collection_hint(text: &str) -> bool {
    match first_non_ws_byte(text) {
        Some(b'-') => {
            has_root_yaml_proxy_list_hint(text)
                || has_root_sing_box_outbound_list_hint(text)
                || yaml_proxy_collection_keys(text).complete()
        }
        Some(b'[') => {
            has_root_json_proxy_list_hint(text)
                || has_root_sing_box_outbound_list_hint(text)
                || yaml_proxy_collection_keys(text).complete()
        }
        Some(b'{') => {
            yaml_proxy_collection_keys(text).complete() || has_wrapped_json_proxy_list_hint(text)
        }
        _ => yaml_proxy_collection_keys(text).complete(),
    }
}

#[derive(Default)]
#[frb(ignore)]
struct YamlProxyCollectionKeys {
    proxies: bool,
    proxy: bool,
    payload: bool,
    outbounds: bool,
}

impl YamlProxyCollectionKeys {
    fn complete(&self) -> bool {
        self.proxies || self.proxy || self.payload || self.outbounds
    }
}

#[derive(Default)]
#[frb(ignore)]
struct WrappedJsonProxyListKeys {
    found: bool,
}

impl WrappedJsonProxyListKeys {
    fn complete(&self) -> bool {
        self.found
    }
}

fn has_wrapped_json_proxy_list_hint(text: &str) -> bool {
    wrapped_json_proxy_list_keys(text).complete() && root_json_proxy_list_keys(text).complete()
}

fn wrapped_json_proxy_list_keys(text: &str) -> WrappedJsonProxyListKeys {
    let bytes = text.as_bytes();
    let mut keys = WrappedJsonProxyListKeys::default();
    let mut index = 0;
    while index < bytes.len() {
        if !is_yaml_key_boundary(bytes, index) {
            index += 1;
            continue;
        }
        match bytes[index].to_ascii_lowercase() {
            b'd' if yaml_key_matches_at(bytes, index, b"data") => keys.found = true,
            b'i' if yaml_key_matches_at(bytes, index, b"items") => keys.found = true,
            b'l' if yaml_key_matches_at(bytes, index, b"list") => keys.found = true,
            b'n' if yaml_key_matches_at(bytes, index, b"nodes") => keys.found = true,
            b'p' if yaml_key_matches_at(bytes, index, b"proxyList")
                || yaml_key_matches_at(bytes, index, b"proxy_list") =>
            {
                keys.found = true;
            }
            b'r' if yaml_key_matches_at(bytes, index, b"records")
                || yaml_key_matches_at(bytes, index, b"response")
                || yaml_key_matches_at(bytes, index, b"result")
                || yaml_key_matches_at(bytes, index, b"results")
                || yaml_key_matches_at(bytes, index, b"rows") =>
            {
                keys.found = true;
            }
            b'e' if yaml_key_matches_at(bytes, index, b"entries") => keys.found = true,
            b's' if yaml_key_matches_at(bytes, index, b"servers") => keys.found = true,
            _ => {}
        }
        if keys.complete() {
            break;
        }
        index += 1;
    }
    keys
}

fn yaml_proxy_collection_keys(text: &str) -> YamlProxyCollectionKeys {
    let bytes = text.as_bytes();
    let mut keys = YamlProxyCollectionKeys::default();
    let mut index = 0;
    while index < bytes.len() {
        if !is_yaml_key_boundary(bytes, index) {
            index += 1;
            continue;
        }
        match bytes[index].to_ascii_lowercase() {
            b'o' if yaml_key_matches_at(bytes, index, b"outbounds") => keys.outbounds = true,
            b'p' if yaml_key_matches_at(bytes, index, b"payload") => keys.payload = true,
            b'p' if yaml_key_matches_at(bytes, index, b"proxies") => keys.proxies = true,
            b'p' if yaml_key_matches_at(bytes, index, b"proxy") => keys.proxy = true,
            _ => {}
        }
        if keys.complete() {
            break;
        }
        index += 1;
    }
    keys
}

fn first_non_ws_byte(text: &str) -> Option<u8> {
    text.as_bytes()
        .iter()
        .copied()
        .find(|byte| !byte.is_ascii_whitespace())
}

fn has_root_yaml_proxy_list_hint(text: &str) -> bool {
    if first_non_ws_byte(text) != Some(b'-') {
        return false;
    }
    let keys = root_yaml_proxy_list_keys(text);
    keys.name && keys.proxy_type && keys.server
}

#[derive(Default)]
#[frb(ignore)]
struct RootYamlProxyListKeys {
    name: bool,
    proxy_type: bool,
    server: bool,
}

impl RootYamlProxyListKeys {
    fn complete(&self) -> bool {
        self.name && self.proxy_type && self.server
    }
}

fn root_yaml_proxy_list_keys(text: &str) -> RootYamlProxyListKeys {
    let bytes = text.as_bytes();
    let mut keys = RootYamlProxyListKeys::default();
    let mut index = 0;
    while index < bytes.len() {
        if !is_yaml_key_boundary(bytes, index) {
            index += 1;
            continue;
        }
        match bytes[index].to_ascii_lowercase() {
            b'n' if yaml_key_matches_at(bytes, index, b"name") => keys.name = true,
            b's' if yaml_key_matches_at(bytes, index, b"server") => keys.server = true,
            b't' if yaml_key_matches_at(bytes, index, b"type") => keys.proxy_type = true,
            _ => {}
        }
        if keys.complete() {
            break;
        }
        index += 1;
    }
    keys
}

fn has_root_json_proxy_list_hint(text: &str) -> bool {
    if first_non_ws_byte(text) != Some(b'[') {
        return false;
    }
    let keys = root_json_proxy_list_keys(text);
    (keys.name && keys.proxy_type && keys.server)
        || (keys.generic_protocol() && keys.generic_server() && (keys.port || keys.server_endpoint))
        || (keys.generic_protocol() && keys.proxy)
}

#[derive(Default)]
#[frb(ignore)]
struct RootJsonProxyListKeys {
    name: bool,
    proxy_type: bool,
    server: bool,
    protocol: bool,
    protocols: bool,
    scheme: bool,
    schemes: bool,
    ip: bool,
    host: bool,
    hostname: bool,
    address: bool,
    addr: bool,
    port: bool,
    proxy: bool,
    server_endpoint: bool,
}

impl RootJsonProxyListKeys {
    fn complete(&self) -> bool {
        (self.name && self.proxy_type && self.server)
            || (self.generic_protocol()
                && self.generic_server()
                && (self.port || self.server_endpoint))
            || (self.generic_protocol() && self.proxy)
    }

    fn generic_protocol(&self) -> bool {
        self.protocol || self.protocols || self.scheme || self.schemes || self.proxy_type
    }

    fn generic_server(&self) -> bool {
        self.ip || self.server || self.host || self.hostname || self.address || self.addr
    }
}

fn root_json_proxy_list_keys(text: &str) -> RootJsonProxyListKeys {
    let bytes = text.as_bytes();
    let mut keys = RootJsonProxyListKeys::default();
    let mut index = 0;
    while index < bytes.len() {
        if bytes[index] != b'"' {
            index += 1;
            continue;
        }
        let key_start = index + 1;
        let Some(key_end) = bytes[key_start..].iter().position(|byte| *byte == b'"') else {
            break;
        };
        let key_end = key_start + key_end;
        let mut cursor = key_end + 1;
        while cursor < bytes.len() && matches!(bytes[cursor], b' ' | b'\t' | b'\r' | b'\n') {
            cursor += 1;
        }
        if cursor >= bytes.len() || bytes[cursor] != b':' {
            index = key_end + 1;
            continue;
        }
        match &bytes[key_start..key_end] {
            key if key.eq_ignore_ascii_case(b"addr") => {
                keys.addr = true;
                mark_root_json_server_endpoint(&mut keys, bytes, cursor + 1);
            }
            key if key.eq_ignore_ascii_case(b"address") => {
                keys.address = true;
                mark_root_json_server_endpoint(&mut keys, bytes, cursor + 1);
            }
            key if key.eq_ignore_ascii_case(b"domain") => {
                keys.host = true;
                mark_root_json_server_endpoint(&mut keys, bytes, cursor + 1);
            }
            key if key.eq_ignore_ascii_case(b"host") => {
                keys.host = true;
                mark_root_json_server_endpoint(&mut keys, bytes, cursor + 1);
            }
            key if key.eq_ignore_ascii_case(b"hostname") => {
                keys.hostname = true;
                mark_root_json_server_endpoint(&mut keys, bytes, cursor + 1);
            }
            key if key.eq_ignore_ascii_case(b"name") => keys.name = true,
            key if key.eq_ignore_ascii_case(b"ipAddress")
                || key.eq_ignore_ascii_case(b"ip_address")
                || key.eq_ignore_ascii_case(b"proxyAddress")
                || key.eq_ignore_ascii_case(b"proxy_address")
                || key.eq_ignore_ascii_case(b"serverAddress")
                || key.eq_ignore_ascii_case(b"server_address") =>
            {
                keys.host = true;
                mark_root_json_server_endpoint(&mut keys, bytes, cursor + 1);
            }
            key if key.eq_ignore_ascii_case(b"type") => keys.proxy_type = true,
            key if key.eq_ignore_ascii_case(b"proxyType")
                || key.eq_ignore_ascii_case(b"proxy_type") =>
            {
                keys.proxy_type = true;
            }
            key if key.eq_ignore_ascii_case(b"server") => {
                keys.server = true;
                mark_root_json_server_endpoint(&mut keys, bytes, cursor + 1);
            }
            key if key.eq_ignore_ascii_case(b"scheme") => keys.scheme = true,
            key if key.eq_ignore_ascii_case(b"schemes") => keys.schemes = true,
            key if key.eq_ignore_ascii_case(b"protocol")
                || key.eq_ignore_ascii_case(b"protocolType")
                || key.eq_ignore_ascii_case(b"protocol_type")
                || key.eq_ignore_ascii_case(b"proxyProtocol")
                || key.eq_ignore_ascii_case(b"proxy_protocol")
                || key.eq_ignore_ascii_case(b"proto") =>
            {
                keys.protocol = true;
            }
            key if key.eq_ignore_ascii_case(b"protocols") => keys.protocols = true,
            key if key.eq_ignore_ascii_case(b"ip") => keys.ip = true,
            key if key.eq_ignore_ascii_case(b"port")
                || key.eq_ignore_ascii_case(b"server_port")
                || key.eq_ignore_ascii_case(b"serverPort")
                || key.eq_ignore_ascii_case(b"remote_port")
                || key.eq_ignore_ascii_case(b"proxyPort")
                || key.eq_ignore_ascii_case(b"proxy_port")
                || key.eq_ignore_ascii_case(b"portNumber")
                || key.eq_ignore_ascii_case(b"port_number")
                || key.eq_ignore_ascii_case(b"ports")
                || key.eq_ignore_ascii_case(b"portList")
                || key.eq_ignore_ascii_case(b"port_list") =>
            {
                keys.port = true;
            }
            key if key.eq_ignore_ascii_case(b"proxy") => keys.proxy = true,
            _ => {}
        }
        if keys.complete() {
            break;
        }
        index = key_end + 1;
    }
    keys
}

fn mark_root_json_server_endpoint(
    keys: &mut RootJsonProxyListKeys,
    bytes: &[u8],
    value_start: usize,
) {
    if json_string_value_has_host_port(bytes, value_start) {
        keys.server_endpoint = true;
    }
}

fn json_string_value_has_host_port(bytes: &[u8], mut cursor: usize) -> bool {
    while cursor < bytes.len() && matches!(bytes[cursor], b' ' | b'\t' | b'\r' | b'\n') {
        cursor += 1;
    }
    if bytes.get(cursor) != Some(&b'"') {
        return false;
    }
    cursor += 1;
    let value_start = cursor;
    let mut escaped = false;
    while cursor < bytes.len() {
        match bytes[cursor] {
            b'\\' if !escaped => escaped = true,
            b'"' if !escaped => return host_port_bytes(&bytes[value_start..cursor]),
            _ => escaped = false,
        }
        cursor += 1;
    }
    false
}

fn host_port_bytes(value: &[u8]) -> bool {
    if let Some(rest) = value.strip_prefix(b"[") {
        let Some(close) = rest.iter().position(|byte| *byte == b']') else {
            return false;
        };
        let port = rest
            .get(close + 1..)
            .and_then(|suffix| suffix.strip_prefix(b":"));
        return rest[..close].contains(&b':') && ascii_port_bytes(port);
    }
    let Some(colon) = value.iter().rposition(|byte| *byte == b':') else {
        return false;
    };
    let server = &value[..colon];
    !server.is_empty()
        && !server.contains(&b':')
        && !server.contains(&b'/')
        && !server.contains(&b'@')
        && ascii_port_bytes(value.get(colon + 1..))
}

fn ascii_port_bytes(value: Option<&[u8]>) -> bool {
    let Some(value) = value else {
        return false;
    };
    !value.is_empty() && value.iter().all(u8::is_ascii_digit)
}

fn has_root_sing_box_outbound_list_hint(text: &str) -> bool {
    if !matches!(first_non_ws_byte(text), Some(b'[' | b'-')) {
        return false;
    }
    let keys = root_sing_box_outbound_keys(text);
    keys.proxy_type
        && keys.server
        && (keys.server_port || keys.server_ports || (keys.port && (keys.tag || !keys.name)))
}

#[derive(Default)]
#[frb(ignore)]
struct RootSingBoxOutboundKeys {
    proxy_type: bool,
    server: bool,
    server_port: bool,
    server_ports: bool,
    port: bool,
    tag: bool,
    name: bool,
}

impl RootSingBoxOutboundKeys {
    fn complete(&self) -> bool {
        self.proxy_type
            && self.server
            && (self.server_port || self.server_ports || (self.port && self.tag))
    }
}

fn root_sing_box_outbound_keys(text: &str) -> RootSingBoxOutboundKeys {
    let bytes = text.as_bytes();
    let mut keys = RootSingBoxOutboundKeys::default();
    let mut index = 0;
    while index < bytes.len() {
        if !is_yaml_key_boundary(bytes, index) {
            index += 1;
            continue;
        }
        match bytes[index].to_ascii_lowercase() {
            b'n' if yaml_key_matches_at(bytes, index, b"name") => keys.name = true,
            b'p' if yaml_key_matches_at(bytes, index, b"port") => keys.port = true,
            b's' if yaml_key_matches_at(bytes, index, b"server_port") => keys.server_port = true,
            b's' if yaml_key_matches_at(bytes, index, b"server_ports") => {
                keys.server_ports = true;
            }
            b's' if yaml_key_matches_at(bytes, index, b"server") => keys.server = true,
            b't' if yaml_key_matches_at(bytes, index, b"type") => keys.proxy_type = true,
            b't' if yaml_key_matches_at(bytes, index, b"tag") => keys.tag = true,
            _ => {}
        }
        if keys.complete() {
            break;
        }
        index += 1;
    }
    keys
}

fn yaml_key_matches_at(bytes: &[u8], index: usize, key: &[u8]) -> bool {
    if index + key.len() > bytes.len() || !bytes[index..index + key.len()].eq_ignore_ascii_case(key)
    {
        return false;
    }
    let mut cursor = index + key.len();
    if cursor < bytes.len() && matches!(bytes[cursor], b'"' | b'\'') {
        cursor += 1;
    }
    while cursor < bytes.len() && matches!(bytes[cursor], b' ' | b'\t') {
        cursor += 1;
    }
    cursor < bytes.len() && bytes[cursor] == b':'
}

fn is_yaml_key_boundary(bytes: &[u8], index: usize) -> bool {
    index == 0
        || matches!(
            bytes[index - 1],
            b'\n' | b'\r' | b' ' | b'\t' | b'{' | b',' | b'"' | b'\''
        )
}

fn has_proxy_uri_hint(text: &str) -> bool {
    proxy_uri_hint_with_schemes(text, &PROXY_URI_SCHEMES)
}

fn has_non_http_proxy_uri_hint(text: &str) -> bool {
    proxy_uri_hint_with_schemes(text, &EMBEDDED_PROXY_URI_SCHEMES)
}

fn proxy_uri_hint_with_schemes(text: &str, schemes: &[&[u8]]) -> bool {
    let text_bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < text.len() {
        if !is_proxy_uri_scheme_start_byte(text_bytes[cursor]) {
            cursor = next_char_boundary(text, cursor);
            continue;
        }
        if proxy_uri_needle_at_with_schemes(text_bytes, cursor, schemes) {
            return true;
        }
        cursor = next_char_boundary(text, cursor);
    }
    false
}

fn decode_base64_text(text: &str) -> Option<String> {
    let padded = if text.len().is_multiple_of(4) {
        Cow::Borrowed(text)
    } else {
        let mut padded = String::with_capacity(text.len() + (4 - text.len() % 4));
        padded.push_str(text);
        while !padded.len().is_multiple_of(4) {
            padded.push('=');
        }
        Cow::Owned(padded)
    };
    STANDARD
        .decode(padded.as_bytes())
        .or_else(|_| URL_SAFE.decode(padded.as_bytes()))
        .ok()
        .and_then(|bytes| String::from_utf8(bytes).ok())
}

fn parse_yaml_proxies(text: &str) -> Vec<Map<String, Value>> {
    let Ok(value) = serde_yaml_ng::from_str::<Value>(text) else {
        return Vec::new();
    };
    let mut object = match value {
        Value::Array(raw) => {
            let mut proxies = Vec::<Map<String, Value>>::with_capacity(raw.len());
            proxies.extend(raw.into_iter().filter_map(normalize_root_proxy_value));
            return proxies;
        }
        Value::Object(object) => object,
        _ => return Vec::new(),
    };

    let raw_proxies = remove_first_yaml_key(
        &mut object,
        &["proxies", "proxy", "payload", "Proxy", "Payload"],
    )
    .and_then(yaml_proxy_values);
    let raw_outbounds =
        remove_first_yaml_key(&mut object, &["outbounds"]).and_then(|value| match value {
            Value::Array(raw) => Some(raw),
            Value::Object(raw) => Some(outbound_map_values(raw)),
            _ => None,
        });
    let mut wrapped_proxy_values = Vec::<Value>::new();
    for key in [
        "data",
        "results",
        "result",
        "response",
        "list",
        "items",
        "records",
        "rows",
        "entries",
        "nodes",
        "servers",
        "proxyList",
        "proxy_list",
    ] {
        if let Some(values) = remove_first_yaml_key(&mut object, &[key]).and_then(yaml_proxy_values)
        {
            wrapped_proxy_values.reserve(values.len());
            wrapped_proxy_values.extend(values);
        }
    }
    let proxy_capacity = raw_proxies.as_ref().map_or(0, Vec::len)
        + raw_outbounds.as_ref().map_or(0, Vec::len)
        + wrapped_proxy_values.len();
    let mut proxies = Vec::<Map<String, Value>>::with_capacity(proxy_capacity);

    if let Some(raw) = raw_proxies {
        proxies.extend(raw.into_iter().filter_map(normalize_proxy_value));
    }
    if let Some(raw) = raw_outbounds {
        proxies.extend(
            raw.into_iter()
                .filter_map(sing_box_outbound_value_to_proxy)
                .filter_map(normalize_proxy),
        );
    }
    proxies.extend(
        wrapped_proxy_values
            .into_iter()
            .filter_map(normalize_root_proxy_value),
    );
    proxies
}

fn yaml_proxy_values(value: Value) -> Option<Vec<Value>> {
    match value {
        Value::Array(raw) => Some(raw),
        Value::Object(mut raw) => {
            yaml_nested_proxy_values(&mut raw).or_else(|| Some(proxy_map_values(raw)))
        }
        _ => None,
    }
}

fn yaml_nested_proxy_values(object: &mut Map<String, Value>) -> Option<Vec<Value>> {
    let mut result = Option::<Vec<Value>>::None;
    for key in [
        "proxies",
        "proxy",
        "payload",
        "data",
        "results",
        "result",
        "response",
        "list",
        "items",
        "records",
        "rows",
        "entries",
        "nodes",
        "servers",
        "proxyList",
        "proxy_list",
    ] {
        if let Some(values) = remove_first_nested_yaml_key(object, key).and_then(yaml_proxy_values)
        {
            let result = result.get_or_insert_with(|| Vec::with_capacity(values.len()));
            result.reserve(values.len());
            result.extend(values);
        }
    }
    result
}

fn remove_first_nested_yaml_key(object: &mut Map<String, Value>, key: &str) -> Option<Value> {
    if object
        .get(key)
        .is_some_and(value_contains_nested_proxy_values)
    {
        return object.remove(key);
    }
    let fallback_key = object
        .iter()
        .find(|(candidate, value)| {
            candidate.eq_ignore_ascii_case(key) && value_contains_nested_proxy_values(value)
        })?
        .0
        .to_string();
    object.remove(&fallback_key)
}

fn value_contains_nested_proxy_values(value: &Value) -> bool {
    match value {
        Value::Array(_) => true,
        Value::Object(object) => object.iter().any(|(key, value)| {
            is_nested_proxy_values_key(key) && value_contains_nested_proxy_values(value)
        }),
        _ => false,
    }
}

fn is_nested_proxy_values_key(key: &str) -> bool {
    [
        "proxies",
        "proxy",
        "payload",
        "data",
        "results",
        "result",
        "response",
        "list",
        "items",
        "records",
        "rows",
        "entries",
        "nodes",
        "servers",
        "proxyList",
        "proxy_list",
    ]
    .iter()
    .any(|candidate| key.eq_ignore_ascii_case(candidate))
}

fn remove_first_yaml_key(object: &mut Map<String, Value>, keys: &[&str]) -> Option<Value> {
    for key in keys {
        if let Some(value) = object.remove(*key) {
            return Some(value);
        }
    }
    let fallback_key = object
        .keys()
        .find(|candidate| keys.iter().any(|key| candidate.eq_ignore_ascii_case(key)))?
        .to_string();
    object.remove(&fallback_key)
}

fn proxy_map_values(raw: Map<String, Value>) -> Vec<Value> {
    let mut values = Vec::with_capacity(raw.len());
    for (name, mut value) in raw {
        if let Value::Object(proxy) = &mut value {
            proxy.entry("name").or_insert_with(|| Value::String(name));
        }
        values.push(value);
    }
    values
}

fn outbound_map_values(raw: Map<String, Value>) -> Vec<Value> {
    let mut values = Vec::with_capacity(raw.len());
    for (tag, mut value) in raw {
        if let Value::Object(outbound) = &mut value {
            outbound.entry("tag").or_insert_with(|| Value::String(tag));
        }
        values.push(value);
    }
    values
}

fn normalize_proxy_value(value: Value) -> Option<Map<String, Value>> {
    match value {
        Value::Object(proxy) => normalize_proxy(proxy),
        _ => None,
    }
}

fn root_sing_box_outbound_to_proxy(outbound: &Map<String, Value>) -> Option<Map<String, Value>> {
    sing_box_outbound_to_proxy(outbound).and_then(normalize_proxy)
}

fn normalize_root_proxy_value(value: Value) -> Option<Map<String, Value>> {
    let Value::Object(proxy) = value else {
        return None;
    };
    normalize_root_proxy_object(proxy)
}

fn normalize_root_proxy_object(proxy: Map<String, Value>) -> Option<Map<String, Value>> {
    if looks_like_sing_box_root_outbound(&proxy) {
        root_sing_box_outbound_to_proxy(&proxy).or_else(|| normalize_proxy(proxy))
    } else if let Some(generic_proxy) = generic_proxy_list_object_to_proxy(&proxy) {
        normalize_proxy(generic_proxy)
    } else {
        normalize_proxy(proxy)
    }
}

fn generic_proxy_list_object_to_proxy(proxy: &Map<String, Value>) -> Option<Map<String, Value>> {
    let uri = proxy
        .get("proxy")
        .and_then(string_value)
        .filter(|value| !value.trim().is_empty());
    let uri = uri.as_deref();
    let mut parsed_uri = Option::<Url>::None;
    let raw_protocol = if let Some(value) = first_generic_proxy_protocol_value(proxy) {
        value
    } else {
        parsed_uri = parse_generic_proxy_uri(uri);
        parsed_uri.as_ref()?.scheme().to_string()
    };
    let proxy_type = generic_proxy_object_type(&raw_protocol)?;
    let mut parsed_endpoint = Option::<(String, i64)>::None;
    let mut parsed_server_endpoint = Option::<(String, i64)>::None;
    let server = if let Some(value) = first_string_value(
        proxy,
        &[
            "server",
            "ip",
            "ipAddress",
            "ip_address",
            "host",
            "hostname",
            "address",
            "addr",
            "domain",
            "proxyAddress",
            "proxy_address",
            "serverAddress",
            "server_address",
        ],
    ) {
        if let Some(endpoint) = parse_generic_proxy_host_port(Some(&value)) {
            let server = endpoint.0.clone();
            parsed_server_endpoint = Some(endpoint);
            server
        } else {
            value
        }
    } else {
        if parsed_uri.is_none() {
            parsed_uri = parse_generic_proxy_uri(uri);
        }
        if let Some(host) = parsed_uri.as_ref().and_then(Url::host_str) {
            host.to_string()
        } else {
            parsed_endpoint = parse_generic_proxy_host_port(uri);
            parsed_endpoint.as_ref()?.0.clone()
        }
    };
    let port = proxy
        .get("port")
        .or_else(|| proxy.get("server_port"))
        .or_else(|| proxy.get("serverPort"))
        .or_else(|| proxy.get("remote_port"))
        .or_else(|| proxy.get("proxyPort"))
        .or_else(|| proxy.get("proxy_port"))
        .or_else(|| proxy.get("portNumber"))
        .or_else(|| proxy.get("port_number"))
        .and_then(parse_port)
        .or_else(|| {
            first_generic_proxy_port_array_value(proxy, &["ports", "portList", "port_list"])
        })
        .or_else(|| parsed_server_endpoint.as_ref().map(|(_, port)| *port))
        .or_else(|| {
            if parsed_uri.is_none() {
                parsed_uri = parse_generic_proxy_uri(uri);
            }
            if let Some(port) = parsed_uri.as_ref().and_then(Url::port).map(i64::from) {
                Some(port)
            } else {
                if parsed_endpoint.is_none() {
                    parsed_endpoint = parse_generic_proxy_host_port(uri);
                }
                parsed_endpoint.as_ref().map(|(_, port)| *port)
            }
        })?;
    let name = first_string_value(proxy, &["name", "tag"])
        .filter(|value| !value.trim().is_empty())
        .unwrap_or_else(|| format!("{proxy_type}-{server}:{port}"));

    let mut normalized = Map::new();
    normalized.insert("name".into(), json!(name));
    normalized.insert("type".into(), json!(proxy_type));
    normalized.insert("server".into(), json!(server));
    normalized.insert("port".into(), json!(port));
    insert_generic_proxy_auth_fields(&mut normalized, proxy);
    insert_generic_proxy_protocol_fields(&mut normalized, proxy, proxy_type);
    insert_generic_proxy_runtime_fields(&mut normalized, proxy);
    Some(normalized)
}

fn parse_generic_proxy_uri(uri: Option<&str>) -> Option<Url> {
    uri.and_then(|value| Url::parse(value).ok())
}

fn insert_generic_proxy_auth_fields(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
) {
    if let Some(username) =
        first_string_value(proxy, &["username", "user"]).filter(|value| !value.trim().is_empty())
    {
        normalized.insert("username".into(), json!(username));
    }
    if let Some(password) =
        first_string_value(proxy, &["password", "pass"]).filter(|value| !value.trim().is_empty())
    {
        normalized.insert("password".into(), json!(password));
    }
}

fn insert_generic_proxy_protocol_fields(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
    proxy_type: &str,
) {
    match proxy_type {
        "ss" => {
            insert_generic_proxy_string(normalized, proxy, "cipher", &["cipher", "method"]);
            insert_generic_proxy_string(normalized, proxy, "password", &["password", "pass"]);
        }
        "ssr" => {
            insert_generic_proxy_string(normalized, proxy, "cipher", &["cipher", "method"]);
            insert_generic_proxy_string(normalized, proxy, "password", &["password", "pass"]);
            insert_generic_proxy_string(normalized, proxy, "protocol", &["protocol", "proto"]);
            insert_generic_proxy_string(normalized, proxy, "obfs", &["obfs"]);
            insert_generic_proxy_string(
                normalized,
                proxy,
                "obfs-param",
                &["obfs-param", "obfs_param", "obfsParam", "obfsparam"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "protocol-param",
                &[
                    "protocol-param",
                    "protocol_param",
                    "protocolParam",
                    "protoparam",
                ],
            );
        }
        "vmess" => {
            insert_generic_proxy_string(normalized, proxy, "uuid", &["uuid", "id"]);
            insert_generic_proxy_string(normalized, proxy, "cipher", &["cipher", "security"]);
            insert_generic_proxy_int(
                normalized,
                proxy,
                "alterId",
                &["alterId", "alter_id", "aid"],
            );
            if !normalized.contains_key("cipher") {
                normalized.insert("cipher".into(), json!("auto"));
            }
        }
        "vless" => {
            insert_generic_proxy_string(normalized, proxy, "uuid", &["uuid", "id"]);
            insert_generic_proxy_string(normalized, proxy, "flow", &["flow"]);
        }
        "trojan" | "hysteria2" | "tuic" | "anytls" => {
            insert_generic_proxy_string(normalized, proxy, "password", &["password", "pass"]);
            if proxy_type == "anytls" {
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "fingerprint",
                    &["hpkp", "pinSHA256", "pin_sha256"],
                );
            }
            if proxy_type == "hysteria2" {
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "fingerprint",
                    &["fingerprint", "pinSHA256", "pin_sha256"],
                );
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "obfs",
                    &["obfs", "obfsType", "obfs_type"],
                );
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "obfs-password",
                    &[
                        "obfs-password",
                        "obfs_password",
                        "obfsPassword",
                        "obfs-pass",
                        "obfs_pass",
                    ],
                );
                insert_generic_proxy_string(normalized, proxy, "up", &["up_mbps", "upmbps", "up"]);
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "down",
                    &["down_mbps", "downmbps", "down"],
                );
                insert_generic_proxy_ports_text(
                    normalized,
                    proxy,
                    "ports",
                    &["ports", "mport", "server_ports", "server-ports"],
                );
                insert_generic_proxy_int(
                    normalized,
                    proxy,
                    "hop-interval",
                    &["hop-interval", "hop_interval", "hopInterval"],
                );
            }
            if proxy_type == "tuic" {
                insert_generic_proxy_string(normalized, proxy, "uuid", &["uuid", "id"]);
                insert_generic_proxy_string(normalized, proxy, "token", &["token"]);
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "congestion-controller",
                    &[
                        "congestion-controller",
                        "congestion_control",
                        "congestionController",
                    ],
                );
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "udp-relay-mode",
                    &["udp-relay-mode", "udp_relay_mode", "udpRelayMode"],
                );
                insert_generic_proxy_int(
                    normalized,
                    proxy,
                    "heartbeat-interval",
                    &[
                        "heartbeat-interval",
                        "heartbeat_interval",
                        "heartbeatInterval",
                    ],
                );
                insert_generic_proxy_int(
                    normalized,
                    proxy,
                    "request-timeout",
                    &["request-timeout", "request_timeout", "requestTimeout"],
                );
                insert_generic_proxy_string(
                    normalized,
                    proxy,
                    "fingerprint",
                    &["fingerprint", "fp"],
                );
                if object_bool_param(proxy, &["disable-sni", "disable_sni", "disableSni"]) {
                    normalized.insert("disable-sni".into(), json!(true));
                }
                if object_bool_param(proxy, &["reduce-rtt", "reduce_rtt", "reduceRtt"]) {
                    normalized.insert("reduce-rtt".into(), json!(true));
                }
                if object_bool_param(
                    proxy,
                    &["udp-over-stream", "udp_over_stream", "udpOverStream"],
                ) {
                    normalized.insert("udp-over-stream".into(), json!(true));
                }
                insert_generic_proxy_int(
                    normalized,
                    proxy,
                    "udp-over-stream-version",
                    &[
                        "udp-over-stream-version",
                        "udp_over_stream_version",
                        "udpOverStreamVersion",
                    ],
                );
                insert_generic_proxy_int(
                    normalized,
                    proxy,
                    "max-open-streams",
                    &["max-open-streams", "max_open_streams", "maxOpenStreams"],
                );
                insert_generic_proxy_int(
                    normalized,
                    proxy,
                    "max-udp-relay-packet-size",
                    &[
                        "max-udp-relay-packet-size",
                        "max_udp_relay_packet_size",
                        "maxUdpRelayPacketSize",
                    ],
                );
            }
        }
        "wireguard" => {
            insert_generic_proxy_string(
                normalized,
                proxy,
                "private-key",
                &["private-key", "private_key", "privateKey"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "public-key",
                &[
                    "public-key",
                    "public_key",
                    "publicKey",
                    "peer_public_key",
                    "peerPublicKey",
                    "pubkey",
                ],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "pre-shared-key",
                &[
                    "pre-shared-key",
                    "pre_shared_key",
                    "preSharedKey",
                    "preshared-key",
                    "preshared_key",
                    "presharedKey",
                    "psk",
                ],
            );
            insert_generic_wireguard_local_address(normalized, proxy);
            insert_generic_proxy_string(normalized, proxy, "reserved", &["reserved"]);
            insert_generic_proxy_int(normalized, proxy, "mtu", &["mtu"]);
            insert_generic_proxy_int(normalized, proxy, "workers", &["workers"]);
            insert_generic_proxy_int(
                normalized,
                proxy,
                "persistent-keepalive",
                &[
                    "persistent-keepalive",
                    "persistent_keepalive",
                    "persistentKeepalive",
                    "keepalive",
                ],
            );
            insert_generic_proxy_int(
                normalized,
                proxy,
                "refresh-server-ip-interval",
                &[
                    "refresh-server-ip-interval",
                    "refresh_server_ip_interval",
                    "refreshServerIpInterval",
                ],
            );
            insert_generic_proxy_csv(
                normalized,
                proxy,
                "allowed-ips",
                &["allowed-ips", "allowed_ips", "allowedIps"],
            );
            insert_generic_proxy_csv(normalized, proxy, "dns", &["dns"]);
            if object_bool_param(
                proxy,
                &[
                    "remote-dns-resolve",
                    "remote_dns_resolve",
                    "remoteDnsResolve",
                ],
            ) {
                normalized.insert("remote-dns-resolve".into(), json!(true));
            }
        }
        "masque" => {
            insert_generic_proxy_string(
                normalized,
                proxy,
                "private-key",
                &["private-key", "private_key", "privateKey"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "public-key",
                &["public-key", "public_key", "publicKey", "pubkey"],
            );
            insert_generic_proxy_string(normalized, proxy, "ip", &["ip", "ipv4"]);
            insert_generic_proxy_string(normalized, proxy, "ipv6", &["ipv6"]);
            insert_generic_proxy_string(
                normalized,
                proxy,
                "uri",
                &["uri", "masque-uri", "masque_uri", "masqueUri"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "congestion-controller",
                &[
                    "congestion-controller",
                    "congestion_controller",
                    "congestionController",
                ],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "bbr-profile",
                &["bbr-profile", "bbr_profile", "bbrProfile"],
            );
            insert_generic_proxy_int(normalized, proxy, "mtu", &["mtu"]);
            insert_generic_proxy_int(normalized, proxy, "cwnd", &["cwnd"]);
            insert_generic_proxy_csv(normalized, proxy, "dns", &["dns"]);
            if object_bool_param(
                proxy,
                &[
                    "remote-dns-resolve",
                    "remote_dns_resolve",
                    "remoteDnsResolve",
                ],
            ) {
                normalized.insert("remote-dns-resolve".into(), json!(true));
            }
        }
        "trusttunnel" => {
            insert_generic_proxy_string(normalized, proxy, "fingerprint", &["fingerprint", "hpkp"]);
            insert_generic_proxy_string(normalized, proxy, "certificate", &["certificate", "cert"]);
            insert_generic_proxy_string(
                normalized,
                proxy,
                "private-key",
                &["private-key", "private_key", "privateKey"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "congestion-controller",
                &[
                    "congestion-controller",
                    "congestion_controller",
                    "congestionController",
                ],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "bbr-profile",
                &["bbr-profile", "bbr_profile", "bbrProfile"],
            );
            if object_bool_param(proxy, &["health-check", "health_check", "healthCheck"]) {
                normalized.insert("health-check".into(), json!(true));
            }
            if object_bool_param(proxy, &["quic"]) {
                normalized.insert("quic".into(), json!(true));
            }
            insert_generic_proxy_int(normalized, proxy, "cwnd", &["cwnd"]);
            insert_generic_proxy_int(
                normalized,
                proxy,
                "max-connections",
                &["max-connections", "max_connections", "maxConnections"],
            );
            insert_generic_proxy_int(
                normalized,
                proxy,
                "min-streams",
                &["min-streams", "min_streams", "minStreams"],
            );
            insert_generic_proxy_int(
                normalized,
                proxy,
                "max-streams",
                &["max-streams", "max_streams", "maxStreams"],
            );
        }
        "ssh" => {
            insert_generic_proxy_string(
                normalized,
                proxy,
                "private-key",
                &["private-key", "private_key", "privateKey"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "private-key-passphrase",
                &[
                    "private-key-passphrase",
                    "private_key_passphrase",
                    "privateKeyPassphrase",
                ],
            );
            insert_generic_proxy_csv(
                normalized,
                proxy,
                "host-key",
                &["host-key", "host_key", "hostKey"],
            );
            insert_generic_proxy_csv(
                normalized,
                proxy,
                "host-key-algorithms",
                &[
                    "host-key-algorithms",
                    "host_key_algorithms",
                    "hostKeyAlgorithms",
                ],
            );
        }
        "mieru" => {
            insert_generic_proxy_string(
                normalized,
                proxy,
                "transport",
                &["transport", "transportProtocol", "transport_protocol"],
            );
            normalized.entry("udp").or_insert_with(|| json!(true));
            insert_generic_proxy_string(
                normalized,
                proxy,
                "multiplexing",
                &["multiplexing", "mux"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "handshake-mode",
                &["handshake-mode", "handshake_mode", "handshakeMode"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "traffic-pattern",
                &["traffic-pattern", "traffic_pattern", "trafficPattern"],
            );
        }
        "snell" => {
            insert_generic_proxy_string(normalized, proxy, "psk", &["psk", "password", "pass"]);
            insert_generic_proxy_int(normalized, proxy, "version", &["version"]);
            insert_generic_snell_obfs_opts(normalized, proxy);
        }
        "hysteria" => {
            insert_generic_proxy_string(
                normalized,
                proxy,
                "auth_str",
                &["auth", "auth_str", "auth-str", "password", "pass"],
            );
            insert_generic_proxy_string(normalized, proxy, "protocol", &["protocol"]);
            insert_generic_proxy_string(normalized, proxy, "up", &["up_mbps", "upmbps", "up"]);
            insert_generic_proxy_string(
                normalized,
                proxy,
                "down",
                &["down_mbps", "downmbps", "down"],
            );
            insert_generic_proxy_ports_text(
                normalized,
                proxy,
                "ports",
                &["ports", "mport", "server_ports", "server-ports"],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "obfs",
                &[
                    "obfs",
                    "obfsPassword",
                    "obfs_password",
                    "obfs-pass",
                    "obfs_pass",
                ],
            );
            insert_generic_proxy_string(
                normalized,
                proxy,
                "obfs-protocol",
                &["obfs-protocol", "obfs_protocol", "obfsProtocol"],
            );
            insert_generic_proxy_int(
                normalized,
                proxy,
                "hop-interval",
                &["hop-interval", "hop_interval", "hopInterval"],
            );
        }
        _ => {}
    }
}

fn insert_generic_proxy_string(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    if let Some(value) =
        first_string_value(proxy, input_keys).filter(|value| !value.trim().is_empty())
    {
        normalized.insert(output_key.into(), json!(value));
    }
}

fn insert_generic_proxy_int(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    for key in input_keys {
        let Some(value) = proxy.get(*key) else {
            continue;
        };
        if let Some(value) = parse_port(value).filter(|value| *value > 0) {
            normalized.insert(output_key.into(), json!(value));
            return;
        }
    }
}

fn insert_generic_proxy_csv(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    for key in input_keys {
        let Some(value) = proxy.get(*key) else {
            continue;
        };
        if let Some(value) = value
            .as_array()
            .and_then(|values| string_values_array_value(values))
        {
            normalized.insert(output_key.into(), value);
            return;
        }
        if let Some(value) = value
            .as_str()
            .and_then(csv_array_value)
            .or_else(|| string_value(value).and_then(|value| csv_array_value(&value)))
        {
            normalized.insert(output_key.into(), value);
            return;
        }
    }
}

fn insert_generic_proxy_ports_text(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    if let Some(value) = first_sing_box_ports_text(proxy, input_keys) {
        normalized.insert(output_key.into(), json!(value));
    }
}

fn insert_generic_wireguard_local_address(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
) {
    insert_generic_proxy_string(
        normalized,
        proxy,
        "ip",
        &["ip", "ipv4", "local_ip", "localIp", "localIPv4"],
    );
    insert_generic_proxy_string(
        normalized,
        proxy,
        "ipv6",
        &["ipv6", "local_ipv6", "localIpv6", "localIPv6"],
    );
    for key in ["local_address", "local-address", "localAddress"] {
        let Some(value) = proxy.get(key) else {
            continue;
        };
        if let Some(address) = string_value(value).filter(|value| !value.trim().is_empty()) {
            insert_wireguard_local_address(normalized, address);
            return;
        }
        if let Some(addresses) = value.as_array() {
            for address in addresses.iter().filter_map(string_value) {
                insert_wireguard_local_address(normalized, address);
            }
            return;
        }
    }
}

fn insert_generic_snell_obfs_opts(normalized: &mut Map<String, Value>, proxy: &Map<String, Value>) {
    let mode = first_string_value(proxy, &["obfs", "mode"]);
    let host = first_string_value(proxy, &["obfs-host", "obfs_host", "obfsHost", "host"]);
    if mode.is_none() && host.is_none() {
        return;
    }
    let mut opts = Map::new();
    if let Some(mode) = mode {
        opts.insert("mode".into(), json!(mode));
    }
    if let Some(host) = host {
        opts.insert("host".into(), json!(host));
    }
    normalized.insert("obfs-opts".into(), Value::Object(opts));
}

fn insert_generic_proxy_runtime_fields(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
) {
    if object_bool_param(
        proxy,
        &[
            "tls",
            "tlsEnabled",
            "tls_enabled",
            "enableTls",
            "enable_tls",
        ],
    ) || generic_proxy_security_is_tls(proxy)
    {
        normalized.insert("tls".into(), json!(true));
    }
    if let Some(sni) = first_string_value(
        proxy,
        &["sni", "servername", "serverName", "server_name", "peer"],
    ) {
        normalized.insert("sni".into(), json!(sni.as_str()));
        normalized.insert("servername".into(), json!(sni));
    }
    if let Some(network) = first_string_value(
        proxy,
        &["network", "transport", "transportType", "transport_type"],
    )
    .and_then(|value| normalize_generic_proxy_network(&value))
    {
        normalized.insert("network".into(), json!(network));
        match network {
            "ws" | "httpupgrade" => insert_generic_proxy_ws_opts(normalized, proxy, network),
            "grpc" => insert_generic_proxy_grpc_opts(normalized, proxy),
            "h2" => insert_generic_proxy_h2_opts(normalized, proxy),
            _ => {}
        }
    }
    insert_generic_proxy_string(
        normalized,
        proxy,
        "client-fingerprint",
        &[
            "client-fingerprint",
            "client_fingerprint",
            "clientFingerprint",
            "fp",
            "fingerprint",
        ],
    );
    if let Some(alpn) = first_string_value(proxy, &["alpn"]) {
        insert_alpn_value(normalized, &alpn);
    }
    if object_bool_param(proxy, &["udp"]) {
        normalized.insert("udp".into(), json!(true));
    }
    if object_bool_param(
        proxy,
        &[
            "allowInsecure",
            "allow_insecure",
            "insecure",
            "skip-cert-verify",
            "skip_cert_verify",
            "skipCertVerify",
        ],
    ) {
        normalized.insert("skip-cert-verify".into(), json!(true));
    }
    insert_generic_proxy_reality_opts(normalized, proxy);
}

fn generic_proxy_security_is_tls(proxy: &Map<String, Value>) -> bool {
    first_string_value(proxy, &["security", "tlsSecurity", "tls_security"]).is_some_and(|value| {
        ends_with_tls_ignore_ascii_case(&value) || value.eq_ignore_ascii_case("reality")
    })
}

fn normalize_generic_proxy_network(value: &str) -> Option<&'static str> {
    if value.eq_ignore_ascii_case("ws") || value.eq_ignore_ascii_case("websocket") {
        Some("ws")
    } else if value.eq_ignore_ascii_case("httpupgrade")
        || value.eq_ignore_ascii_case("http-upgrade")
    {
        Some("httpupgrade")
    } else if value.eq_ignore_ascii_case("grpc") {
        Some("grpc")
    } else if value.eq_ignore_ascii_case("http") || value.eq_ignore_ascii_case("h2") {
        Some("h2")
    } else if value.eq_ignore_ascii_case("tcp") {
        Some("tcp")
    } else {
        None
    }
}

fn insert_generic_proxy_ws_opts(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
    network: &str,
) {
    if network != "ws" && network != "httpupgrade" {
        return;
    }
    let path = first_string_value(proxy, &["path", "wsPath", "ws_path"]);
    let host = first_string_value(proxy, &["host", "wsHost", "ws_host"]);
    if path.is_none() && host.is_none() {
        return;
    }
    let mut opts = Map::new();
    if let Some(path) = path {
        opts.insert("path".into(), json!(path));
    }
    if let Some(host) = host {
        let mut headers = Map::new();
        headers.insert("Host".into(), json!(host));
        opts.insert("headers".into(), Value::Object(headers));
    }
    normalized.insert("ws-opts".into(), Value::Object(opts));
}

fn insert_generic_proxy_grpc_opts(normalized: &mut Map<String, Value>, proxy: &Map<String, Value>) {
    let Some(service_name) = first_string_value(
        proxy,
        &[
            "serviceName",
            "service_name",
            "grpcServiceName",
            "grpc_service_name",
            "grpc-service-name",
        ],
    ) else {
        return;
    };
    let mut opts = Map::new();
    opts.insert("grpc-service-name".into(), json!(service_name));
    normalized.insert("grpc-opts".into(), Value::Object(opts));
}

fn insert_generic_proxy_h2_opts(normalized: &mut Map<String, Value>, proxy: &Map<String, Value>) {
    let path = first_string_value(proxy, &["path", "h2Path", "h2_path"]);
    let host = first_string_value(proxy, &["host", "h2Host", "h2_host"]);
    if path.is_none() && host.is_none() {
        return;
    }
    let mut opts = Map::new();
    if let Some(path) = path {
        opts.insert("path".into(), json!([path]));
    }
    if let Some(host) = host {
        opts.insert("host".into(), json!([host]));
    }
    normalized.insert("h2-opts".into(), Value::Object(opts));
}

fn insert_generic_proxy_reality_opts(
    normalized: &mut Map<String, Value>,
    proxy: &Map<String, Value>,
) {
    let mut opts = Map::new();
    if let Some(public_key) = first_string_value(
        proxy,
        &["pbk", "public-key", "publicKey", "public_key", "pubkey"],
    ) {
        opts.insert("public-key".into(), json!(public_key));
    }
    if let Some(short_id) = first_string_value(proxy, &["sid", "short-id", "shortId", "short_id"])
        .filter(|value| is_valid_reality_short_id(value))
    {
        opts.insert("short-id".into(), json!(short_id));
    }
    if let Some(reality) = proxy.get("reality").and_then(Value::as_object) {
        if reality.get("enabled").and_then(Value::as_bool) != Some(false) {
            if let Some(public_key) =
                object_string_param(reality, &["public_key", "public-key", "publicKey", "pbk"])
            {
                opts.insert("public-key".into(), json!(public_key));
            }
            if let Some(short_id) =
                object_string_param(reality, &["short_id", "short-id", "shortId", "sid"])
                    .filter(|value| is_valid_reality_short_id(value))
            {
                opts.insert("short-id".into(), json!(short_id));
            }
        }
    }
    if !opts.is_empty() {
        normalized.insert("reality-opts".into(), Value::Object(opts));
    }
}

fn parse_generic_proxy_host_port(value: Option<&str>) -> Option<(String, i64)> {
    let value = value?.trim();
    if value.is_empty() || value.contains("://") {
        return None;
    }
    let (server, port) = if let Some(rest) = value.strip_prefix('[') {
        let (server, port) = rest.split_once("]:")?;
        (server.trim(), port.trim())
    } else {
        let (server, port) = value.rsplit_once(':')?;
        (server.trim(), port.trim())
    };
    if server.is_empty() || port.is_empty() || server.contains('/') || server.contains('@') {
        return None;
    }
    let port = port.parse::<i64>().ok()?;
    Some((server.to_string(), port))
}

fn first_generic_proxy_port_array_value(proxy: &Map<String, Value>, keys: &[&str]) -> Option<i64> {
    for key in keys {
        let Some(values) = proxy.get(*key).and_then(Value::as_array) else {
            continue;
        };
        if let Some(port) = values.iter().find_map(parse_port) {
            return Some(port);
        }
    }
    None
}

fn first_string_value(proxy: &Map<String, Value>, keys: &[&str]) -> Option<String> {
    keys.iter()
        .filter_map(|key| proxy.get(*key).and_then(string_value))
        .find(|value| !value.trim().is_empty())
}

fn first_generic_proxy_protocol_value(proxy: &Map<String, Value>) -> Option<String> {
    [
        "protocol",
        "protocolType",
        "protocol_type",
        "proxyProtocol",
        "proxy_protocol",
        "proto",
        "scheme",
        "type",
        "proxyType",
        "proxy_type",
    ]
    .iter()
    .filter_map(|key| proxy.get(*key).and_then(string_value))
    .find(|value| generic_proxy_object_type(value).is_some())
    .or_else(|| first_supported_string_array_value(proxy, &["protocols", "schemes"]))
}

fn first_supported_string_array_value(proxy: &Map<String, Value>, keys: &[&str]) -> Option<String> {
    for key in keys {
        let Some(values) = proxy.get(*key).and_then(Value::as_array) else {
            continue;
        };
        if let Some(value) = values
            .iter()
            .filter_map(string_value)
            .find(|value| generic_proxy_object_type(value).is_some())
        {
            return Some(value);
        }
    }
    None
}

fn generic_proxy_object_type(value: &str) -> Option<&'static str> {
    generic_proxy_list_type(value).or_else(|| {
        if value.eq_ignore_ascii_case("masque") {
            Some("masque")
        } else if value.eq_ignore_ascii_case("trusttunnel") {
            Some("trusttunnel")
        } else if value.eq_ignore_ascii_case("mieru") || value.eq_ignore_ascii_case("mierus") {
            Some("mieru")
        } else if value.eq_ignore_ascii_case("snell") {
            Some("snell")
        } else {
            None
        }
    })
}

fn generic_proxy_list_type(value: &str) -> Option<&'static str> {
    if value.eq_ignore_ascii_case("http") || value.eq_ignore_ascii_case("https") {
        Some("http")
    } else if value.eq_ignore_ascii_case("socks")
        || value.eq_ignore_ascii_case("socks5")
        || value.eq_ignore_ascii_case("socks5h")
    {
        Some("socks5")
    } else if value.eq_ignore_ascii_case("ssr") || value.eq_ignore_ascii_case("shadowsocksr") {
        Some("ssr")
    } else {
        sing_box_proxy_type(value)
    }
}

fn is_unsupported_generic_proxy_list_type(value: &str) -> bool {
    value.eq_ignore_ascii_case("socks4")
}

fn looks_like_sing_box_root_outbound(proxy: &Map<String, Value>) -> bool {
    proxy.contains_key("server")
        && proxy.contains_key("type")
        && (proxy.contains_key("server_port")
            || proxy.contains_key("server_ports")
            || (proxy.contains_key("port")
                && (proxy.contains_key("tag") || !proxy.contains_key("name"))))
        && (!proxy.contains_key("name") || !proxy.contains_key("port"))
}

fn sing_box_outbound_value_to_proxy(value: Value) -> Option<Map<String, Value>> {
    let Value::Object(outbound) = value else {
        return None;
    };
    sing_box_outbound_to_proxy(&outbound)
}

fn sing_box_outbound_to_proxy(outbound: &Map<String, Value>) -> Option<Map<String, Value>> {
    let raw_type = string_value(outbound.get("type")?)?;
    let proxy_type = sing_box_proxy_type(&raw_type)?;
    let server = string_value(outbound.get("server")?)?;
    let port = sing_box_outbound_port(outbound)?;
    let name = outbound
        .get("tag")
        .and_then(string_value)
        .filter(|tag| !tag.trim().is_empty())
        .unwrap_or_else(|| format!("{proxy_type}-{server}"));
    let mut proxy = Map::new();
    proxy.insert("name".into(), json!(name));
    proxy.insert("type".into(), json!(proxy_type));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));

    match proxy_type {
        "ss" => {
            insert_sing_box_string(&mut proxy, outbound, "cipher", &["method"]);
            insert_sing_box_string(&mut proxy, outbound, "password", &["password"]);
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
        }
        "vmess" => {
            insert_sing_box_string(&mut proxy, outbound, "uuid", &["uuid"]);
            insert_sing_box_string(&mut proxy, outbound, "cipher", &["security"]);
            if !proxy.contains_key("cipher") {
                proxy.insert("cipher".into(), json!("auto"));
            }
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
        }
        "vless" => {
            insert_sing_box_string(&mut proxy, outbound, "uuid", &["uuid"]);
            insert_sing_box_string(&mut proxy, outbound, "flow", &["flow"]);
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
        }
        "trojan" | "hysteria2" => {
            insert_sing_box_string(&mut proxy, outbound, "password", &["password"]);
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
        }
        "hysteria" => {
            insert_sing_box_string(
                &mut proxy,
                outbound,
                "auth_str",
                &["auth", "auth_str", "auth-str", "password"],
            );
            insert_sing_box_string(&mut proxy, outbound, "protocol", &["protocol"]);
            insert_sing_box_string(&mut proxy, outbound, "up", &["up_mbps", "up"]);
            insert_sing_box_string(&mut proxy, outbound, "down", &["down_mbps", "down"]);
            insert_sing_box_ports_text(
                &mut proxy,
                outbound,
                "ports",
                &["server_ports", "server-ports", "ports"],
            );
            insert_sing_box_string(&mut proxy, outbound, "obfs", &["obfs"]);
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
        }
        "tuic" => {
            insert_sing_box_string(&mut proxy, outbound, "uuid", &["uuid"]);
            insert_sing_box_string(&mut proxy, outbound, "password", &["password"]);
            insert_sing_box_string(
                &mut proxy,
                outbound,
                "congestion-controller",
                &["congestion_control", "congestion-controller"],
            );
            insert_sing_box_string(
                &mut proxy,
                outbound,
                "udp-relay-mode",
                &["udp_relay_mode", "udp-relay-mode"],
            );
        }
        "anytls" => {
            insert_sing_box_string(&mut proxy, outbound, "username", &["username", "user"]);
            insert_sing_box_string(&mut proxy, outbound, "password", &["password"]);
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
        }
        "wireguard" => {
            insert_sing_box_string(&mut proxy, outbound, "private-key", &["private_key"]);
            insert_sing_box_string(
                &mut proxy,
                outbound,
                "public-key",
                &["peer_public_key", "public_key"],
            );
            insert_sing_box_string(
                &mut proxy,
                outbound,
                "pre-shared-key",
                &["pre_shared_key", "preshared_key"],
            );
            insert_sing_box_local_address(&mut proxy, outbound);
            insert_sing_box_string(&mut proxy, outbound, "reserved", &["reserved"]);
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
            insert_sing_box_int(&mut proxy, outbound, "mtu", &["mtu"]);
        }
        "socks5" => {
            insert_sing_box_string(&mut proxy, outbound, "username", &["username", "user"]);
            insert_sing_box_string(&mut proxy, outbound, "password", &["password", "pass"]);
            insert_sing_box_bool(&mut proxy, outbound, "udp", &["udp"]);
        }
        "http" => {
            insert_sing_box_string(&mut proxy, outbound, "username", &["username", "user"]);
            insert_sing_box_string(&mut proxy, outbound, "password", &["password", "pass"]);
        }
        "ssh" => {
            insert_sing_box_string(&mut proxy, outbound, "username", &["username", "user"]);
            if !proxy.contains_key("username") {
                return None;
            }
            insert_sing_box_string(&mut proxy, outbound, "password", &["password", "pass"]);
            insert_sing_box_string(&mut proxy, outbound, "private-key", &["private_key"]);
            insert_sing_box_string(
                &mut proxy,
                outbound,
                "private-key-passphrase",
                &["private_key_passphrase"],
            );
        }
        _ => {}
    }

    insert_sing_box_tls_opts(&mut proxy, outbound);
    insert_sing_box_transport_opts(&mut proxy, outbound);
    insert_sing_box_hysteria2_opts(&mut proxy, outbound);
    Some(proxy)
}

fn sing_box_outbound_port(outbound: &Map<String, Value>) -> Option<i64> {
    outbound
        .get("server_port")
        .or_else(|| outbound.get("server-port"))
        .or_else(|| outbound.get("port"))
        .and_then(parse_port)
        .or_else(|| first_port_from_sing_box_ports(outbound))
}

fn first_port_from_sing_box_ports(outbound: &Map<String, Value>) -> Option<i64> {
    let ports = first_sing_box_ports_text(outbound, &["server_ports", "server-ports", "ports"])?;
    ports
        .split(|ch: char| !ch.is_ascii_digit())
        .find(|part| !part.is_empty())
        .and_then(|part| part.parse::<i64>().ok())
}

fn sing_box_proxy_type(value: &str) -> Option<&'static str> {
    if value.eq_ignore_ascii_case("shadowsocks") || value.eq_ignore_ascii_case("ss") {
        Some("ss")
    } else if value.eq_ignore_ascii_case("vmess") {
        Some("vmess")
    } else if value.eq_ignore_ascii_case("vless") {
        Some("vless")
    } else if value.eq_ignore_ascii_case("trojan") {
        Some("trojan")
    } else if value.eq_ignore_ascii_case("hysteria") || value.eq_ignore_ascii_case("hy") {
        Some("hysteria")
    } else if value.eq_ignore_ascii_case("hysteria2") || value.eq_ignore_ascii_case("hy2") {
        Some("hysteria2")
    } else if value.eq_ignore_ascii_case("tuic") {
        Some("tuic")
    } else if value.eq_ignore_ascii_case("anytls") {
        Some("anytls")
    } else if value.eq_ignore_ascii_case("wireguard") || value.eq_ignore_ascii_case("wg") {
        Some("wireguard")
    } else if value.eq_ignore_ascii_case("socks") || value.eq_ignore_ascii_case("socks5") {
        Some("socks5")
    } else if value.eq_ignore_ascii_case("http") {
        Some("http")
    } else if value.eq_ignore_ascii_case("ssh") {
        Some("ssh")
    } else {
        None
    }
}

fn insert_sing_box_string(
    proxy: &mut Map<String, Value>,
    outbound: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    if let Some(value) = first_sing_box_string(outbound, input_keys) {
        proxy.insert(output_key.into(), json!(value));
    }
}

fn insert_sing_box_ports_text(
    proxy: &mut Map<String, Value>,
    outbound: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    if let Some(value) = first_sing_box_ports_text(outbound, input_keys) {
        proxy.insert(output_key.into(), json!(value));
    }
}

fn insert_sing_box_bool(
    proxy: &mut Map<String, Value>,
    outbound: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    for key in input_keys {
        if let Some(value) = outbound.get(*key).and_then(Value::as_bool) {
            proxy.insert(output_key.into(), json!(value));
            return;
        }
    }
}

fn insert_sing_box_int(
    proxy: &mut Map<String, Value>,
    outbound: &Map<String, Value>,
    output_key: &str,
    input_keys: &[&str],
) {
    for key in input_keys {
        if let Some(value) = outbound.get(*key).and_then(parse_port) {
            proxy.insert(output_key.into(), json!(value));
            return;
        }
    }
}

fn insert_sing_box_local_address(proxy: &mut Map<String, Value>, outbound: &Map<String, Value>) {
    let Some(value) = outbound
        .get("local_address")
        .or_else(|| outbound.get("local-address"))
    else {
        return;
    };
    if let Some(address) = string_value(value).filter(|value| !value.trim().is_empty()) {
        insert_wireguard_local_address(proxy, address);
        return;
    }
    let Some(addresses) = value.as_array() else {
        return;
    };
    for address in addresses.iter().filter_map(string_value) {
        insert_wireguard_local_address(proxy, address);
    }
}

fn insert_wireguard_local_address(proxy: &mut Map<String, Value>, address: String) {
    if address.contains(':') {
        proxy.entry("ipv6").or_insert_with(|| json!(address));
    } else {
        proxy.entry("ip").or_insert_with(|| json!(address));
    }
}

fn first_sing_box_string(outbound: &Map<String, Value>, keys: &[&str]) -> Option<String> {
    keys.iter()
        .filter_map(|key| outbound.get(*key).and_then(string_value))
        .find(|value| !value.trim().is_empty())
}

fn first_sing_box_ports_text(outbound: &Map<String, Value>, keys: &[&str]) -> Option<String> {
    keys.iter()
        .filter_map(|key| outbound.get(*key).and_then(sing_box_ports_text))
        .find(|value| !value.trim().is_empty())
}

fn sing_box_ports_text(value: &Value) -> Option<String> {
    if let Some(value) = string_value(value) {
        return Some(value);
    }
    let values = value.as_array()?;
    let mut ports = String::new();
    for value in values.iter().filter_map(string_value) {
        if value.trim().is_empty() {
            continue;
        }
        if !ports.is_empty() {
            ports.push(',');
        }
        ports.push_str(value.trim());
    }
    (!ports.is_empty()).then_some(ports)
}

fn insert_sing_box_tls_opts(proxy: &mut Map<String, Value>, outbound: &Map<String, Value>) {
    let Some(tls) = outbound.get("tls").and_then(Value::as_object) else {
        return;
    };
    if tls.get("enabled").and_then(Value::as_bool) == Some(false) {
        return;
    }
    proxy.insert("tls".into(), json!(true));
    if let Some(sni) = tls
        .get("server_name")
        .or_else(|| tls.get("server-name"))
        .and_then(string_value)
        .filter(|value| !value.trim().is_empty())
    {
        proxy.insert("sni".into(), json!(sni));
    }
    if let Some(insecure) = tls.get("insecure").and_then(Value::as_bool) {
        proxy.insert("skip-cert-verify".into(), json!(insecure));
    }
    if let Some(alpn) = tls.get("alpn").and_then(Value::as_array) {
        if let Some(value) = string_values_array_value(alpn) {
            proxy.insert("alpn".into(), value);
        }
    }
    if let Some(utls) = tls.get("utls").and_then(Value::as_object) {
        if utls.get("enabled").and_then(Value::as_bool) != Some(false) {
            if let Some(fingerprint) = utls
                .get("fingerprint")
                .and_then(string_value)
                .filter(|value| !value.trim().is_empty())
            {
                proxy.insert("client-fingerprint".into(), json!(fingerprint));
            }
        }
    }
    if let Some(reality) = tls.get("reality").and_then(Value::as_object) {
        if reality.get("enabled").and_then(Value::as_bool) != Some(false) {
            let mut opts = Map::new();
            if let Some(public_key) = reality
                .get("public_key")
                .or_else(|| reality.get("public-key"))
                .and_then(string_value)
                .filter(|value| !value.trim().is_empty())
            {
                opts.insert("public-key".into(), json!(public_key));
            }
            if let Some(short_id) = reality
                .get("short_id")
                .or_else(|| reality.get("short-id"))
                .and_then(string_value)
                .filter(|value| is_valid_reality_short_id(value))
            {
                opts.insert("short-id".into(), json!(short_id));
            }
            if !opts.is_empty() {
                proxy.insert("reality-opts".into(), Value::Object(opts));
            }
        }
    }
}

fn insert_sing_box_transport_opts(proxy: &mut Map<String, Value>, outbound: &Map<String, Value>) {
    let Some(transport) = outbound.get("transport").and_then(Value::as_object) else {
        return;
    };
    let Some(raw_type) = transport.get("type").and_then(string_value) else {
        return;
    };
    if raw_type.eq_ignore_ascii_case("ws") || raw_type.eq_ignore_ascii_case("websocket") {
        proxy.insert("network".into(), json!("ws"));
        let mut opts = Map::new();
        if let Some(path) = transport
            .get("path")
            .and_then(string_value)
            .filter(|value| !value.trim().is_empty())
        {
            opts.insert("path".into(), json!(path));
        }
        if let Some(headers) = transport.get("headers").and_then(Value::as_object) {
            if let Some(host) = headers
                .get("Host")
                .or_else(|| headers.get("host"))
                .and_then(sing_box_header_value)
                .filter(|value| !value.trim().is_empty())
            {
                opts.insert("headers".into(), json!({ "Host": host }));
            }
        }
        if !opts.is_empty() {
            proxy.insert("ws-opts".into(), Value::Object(opts));
        }
    } else if raw_type.eq_ignore_ascii_case("grpc") {
        proxy.insert("network".into(), json!("grpc"));
        let mut opts = Map::new();
        if let Some(service_name) = transport
            .get("service_name")
            .or_else(|| transport.get("service-name"))
            .and_then(string_value)
            .filter(|value| !value.trim().is_empty())
        {
            opts.insert("grpc-service-name".into(), json!(service_name));
        }
        if !opts.is_empty() {
            proxy.insert("grpc-opts".into(), Value::Object(opts));
        }
    } else if raw_type.eq_ignore_ascii_case("http") {
        proxy.insert("network".into(), json!("h2"));
        let mut opts = Map::new();
        if let Some(path) = transport
            .get("path")
            .and_then(string_value)
            .filter(|value| !value.trim().is_empty())
        {
            opts.insert("path".into(), json!(path));
        }
        if let Some(host) = transport
            .get("host")
            .and_then(sing_box_header_value)
            .filter(|value| !value.trim().is_empty())
        {
            opts.insert("host".into(), json!([host]));
        }
        if !opts.is_empty() {
            proxy.insert("h2-opts".into(), Value::Object(opts));
        }
    }
}

fn sing_box_header_value(value: &Value) -> Option<String> {
    if let Some(value) = string_value(value) {
        return Some(value);
    }
    value
        .as_array()
        .and_then(|values| values.iter().find_map(string_value))
}

fn insert_sing_box_hysteria2_opts(proxy: &mut Map<String, Value>, outbound: &Map<String, Value>) {
    let is_hysteria2 = proxy
        .get("type")
        .and_then(Value::as_str)
        .is_some_and(|value| value == "hysteria2");
    if !is_hysteria2 {
        return;
    }
    insert_sing_box_string(proxy, outbound, "up", &["up_mbps", "up"]);
    insert_sing_box_string(proxy, outbound, "down", &["down_mbps", "down"]);
    insert_sing_box_ports_text(
        proxy,
        outbound,
        "ports",
        &["server_ports", "server-ports", "ports"],
    );
    if let Some(obfs) = outbound.get("obfs").and_then(Value::as_object) {
        if let Some(obfs_type) = obfs
            .get("type")
            .and_then(string_value)
            .filter(|value| !value.trim().is_empty())
        {
            proxy.insert("obfs".into(), json!(obfs_type));
        }
        if let Some(password) = obfs
            .get("password")
            .and_then(string_value)
            .filter(|value| !value.trim().is_empty())
        {
            proxy.insert("obfs-password".into(), json!(password));
        }
    }
}

const MAX_FREE_NODE_PROXY_URI_BYTES: usize = 64 * 1024;
const MAX_FREE_NODE_PROXY_URI_QUERY_PAIRS: usize = 256;

fn proxy_uri_exceeds_complexity_limit(value: &str) -> bool {
    if value.len() > MAX_FREE_NODE_PROXY_URI_BYTES {
        return true;
    }
    let Some((_, tail)) = value.split_once('?') else {
        return false;
    };
    let query = tail.split('#').next().unwrap_or(tail);
    query_pair_capacity(query) > MAX_FREE_NODE_PROXY_URI_QUERY_PAIRS
}

fn parse_uri_proxies(text: &str) -> Vec<Map<String, Value>> {
    let mut seen = UriDedupSet::new();
    let mut seen_values = Vec::<String>::new();
    let mut proxies = Option::<Vec<Map<String, Value>>>::None;
    let text_bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < text.len() {
        if !is_proxy_uri_scheme_start_byte(text_bytes[cursor]) {
            cursor = next_char_boundary(text, cursor);
            continue;
        }
        if !proxy_uri_needle_at(text_bytes, cursor) {
            cursor = next_char_boundary(text, cursor);
            continue;
        }
        let start = cursor;
        let end = find_proxy_uri_end(text, start);
        cursor = if end < text.len() {
            next_char_boundary(text, end)
        } else {
            text.len()
        };
        if end.saturating_sub(start) > MAX_FREE_NODE_PROXY_URI_BYTES {
            continue;
        }
        let value = normalize_proxy_uri_text(&text[start..end]);
        if value.is_empty() {
            continue;
        }
        if !seen.insert(&seen_values, &value) {
            continue;
        }
        if starts_with_ascii_case_insensitive(&value, "mierus://")
            || starts_with_ascii_case_insensitive(&value, "mieru://")
        {
            append_uri_proxies(
                &mut proxies,
                parse_mierus_proxies(&value)
                    .into_iter()
                    .filter_map(normalize_proxy),
            );
            seen_values.push(value);
            continue;
        }
        if let Some(proxy) = parse_uri_proxy(&value).and_then(normalize_proxy) {
            push_uri_proxy(&mut proxies, proxy);
        }
        seen_values.push(value);
    }
    proxies.unwrap_or_default()
}

fn append_uri_proxies<I>(proxies: &mut Option<Vec<Map<String, Value>>>, parsed: I)
where
    I: IntoIterator<Item = Map<String, Value>>,
{
    for proxy in parsed {
        push_uri_proxy(proxies, proxy);
    }
}

fn push_uri_proxy(proxies: &mut Option<Vec<Map<String, Value>>>, proxy: Map<String, Value>) {
    if let Some(proxies) = proxies.as_mut() {
        proxies.push(proxy);
        return;
    }
    let mut first = Vec::with_capacity(1);
    first.extend([proxy]);
    *proxies = Some(first);
}

fn parse_uri_proxy(value: &str) -> Option<Map<String, Value>> {
    if proxy_uri_exceeds_complexity_limit(value) {
        return None;
    }
    let first = value.as_bytes().first()?.to_ascii_lowercase();
    match first {
        b'a' if starts_with_ascii_case_insensitive(value, "anytls://") => parse_anytls_proxy(value),
        b'h' if starts_with_ascii_case_insensitive(value, "hysteria://")
            || starts_with_ascii_case_insensitive(value, "hysteria1://")
            || starts_with_ascii_case_insensitive(value, "hy://") =>
        {
            parse_hysteria_proxy(value)
        }
        b'h' if starts_with_ascii_case_insensitive(value, "hysteria2://")
            || starts_with_ascii_case_insensitive(value, "hy2://") =>
        {
            parse_hysteria2_proxy(value)
        }
        b'h' if starts_with_ascii_case_insensitive(value, "http://")
            || starts_with_ascii_case_insensitive(value, "https://") =>
        {
            parse_http_proxy(value)
        }
        b'm' if starts_with_ascii_case_insensitive(value, "masque://") => parse_masque_proxy(value),
        b'm' if starts_with_ascii_case_insensitive(value, "mierus://")
            || starts_with_ascii_case_insensitive(value, "mieru://") =>
        {
            None
        }
        b's' if starts_with_ascii_case_insensitive(value, "ss://") => parse_ss_proxy(value),
        b's' if starts_with_ascii_case_insensitive(value, "ssr://") => parse_ssr_proxy(value),
        b's' if starts_with_ascii_case_insensitive(value, "snell://") => parse_snell_proxy(value),
        b's' if starts_with_ascii_case_insensitive(value, "socks5h://")
            || starts_with_ascii_case_insensitive(value, "socks5://")
            || starts_with_ascii_case_insensitive(value, "socks://") =>
        {
            parse_socks_proxy(value)
        }
        b's' if starts_with_ascii_case_insensitive(value, "ssh://") => parse_ssh_proxy(value),
        b't' if starts_with_ascii_case_insensitive(value, "trojan://") => {
            parse_user_info_proxy(value, "trojan")
        }
        b't' if starts_with_ascii_case_insensitive(value, "tuic://") => parse_tuic_proxy(value),
        b't' if starts_with_ascii_case_insensitive(value, "trusttunnel://") => {
            parse_trusttunnel_proxy(value)
        }
        b'v' if starts_with_ascii_case_insensitive(value, "vless://") => {
            parse_user_info_proxy(value, "vless")
        }
        b'v' if starts_with_ascii_case_insensitive(value, "vmess://") => parse_vmess_proxy(value),
        b'w' if starts_with_ascii_case_insensitive(value, "wireguard://")
            || starts_with_ascii_case_insensitive(value, "wg://") =>
        {
            parse_wireguard_proxy(value)
        }
        _ => None,
    }
}

fn proxy_uri_needle_at(bytes: &[u8], index: usize) -> bool {
    proxy_uri_needle_at_with_schemes(bytes, index, &PROXY_URI_SCHEMES)
}

fn is_proxy_uri_scheme_start_byte(byte: u8) -> bool {
    matches!(byte | 0x20, b'a' | b'h' | b'm' | b's' | b't' | b'v' | b'w')
}

fn proxy_uri_needle_at_with_schemes(bytes: &[u8], index: usize, schemes: &[&[u8]]) -> bool {
    let bytes = &bytes[index..];
    if bytes.is_empty() {
        return false;
    }
    let first = bytes[0] | 0x20;
    schemes.iter().any(|scheme| {
        let scheme = *scheme;
        let start = scheme.len();
        !scheme.is_empty()
            && (scheme[0] | 0x20) == first
            && bytes.len() >= start + 3
            && bytes[..start].eq_ignore_ascii_case(scheme)
            && PROXY_URI_SEPARATORS.iter().any(|separator| {
                bytes.len() >= start + separator.len()
                    && bytes[start..start + separator.len()].eq_ignore_ascii_case(separator)
            })
    })
}

fn next_char_boundary(text: &str, index: usize) -> usize {
    if text.as_bytes()[index].is_ascii() {
        return index + 1;
    }
    text[index..]
        .chars()
        .next()
        .map(|c| index + c.len_utf8())
        .unwrap_or(text.len())
}

fn find_proxy_uri_end(text: &str, start: usize) -> usize {
    text[start..]
        .char_indices()
        .skip(1)
        .find_map(|(offset, c)| is_proxy_uri_delimiter(c).then_some(start + offset))
        .unwrap_or(text.len())
}

fn starts_with_ascii_case_insensitive(value: &str, prefix: &str) -> bool {
    let value = value.as_bytes();
    let prefix = prefix.as_bytes();
    value.len() >= prefix.len() && value[..prefix.len()].eq_ignore_ascii_case(prefix)
}

fn ends_with_ascii_case_insensitive(value: &str, suffix: &str) -> bool {
    let value = value.as_bytes();
    let suffix = suffix.as_bytes();
    value.len() >= suffix.len() && value[value.len() - suffix.len()..].eq_ignore_ascii_case(suffix)
}

fn contains_ascii_case_insensitive(value: &str, needle: &str) -> bool {
    let value = value.as_bytes();
    let needle = needle.as_bytes();
    if needle.is_empty() || value.len() < needle.len() {
        return false;
    }
    let first = needle[0].to_ascii_lowercase();
    let max_start = value.len() - needle.len();
    let mut index = 0;
    while index <= max_start {
        if value[index].to_ascii_lowercase() == first
            && value[index..index + needle.len()].eq_ignore_ascii_case(needle)
        {
            return true;
        }
        index += 1;
    }
    false
}

fn contains_any_ascii_case_insensitive(value: &str, needles: &[&str]) -> bool {
    let value = value.as_bytes();
    if value.is_empty() || needles.is_empty() {
        return false;
    }
    let mut first_bytes = [false; 256];
    for needle in needles {
        let needle = needle.as_bytes();
        if let Some(first) = needle.first() {
            first_bytes[first.to_ascii_lowercase() as usize] = true;
        }
    }
    let mut index = 0;
    while index < value.len() {
        let current = value[index].to_ascii_lowercase();
        if !first_bytes[current as usize] {
            index += 1;
            continue;
        }
        for needle in needles {
            let needle = needle.as_bytes();
            if needle.is_empty() || index + needle.len() > value.len() {
                continue;
            }
            if current == needle[0].to_ascii_lowercase()
                && value[index..index + needle.len()].eq_ignore_ascii_case(needle)
            {
                return true;
            }
        }
        index += 1;
    }
    false
}

fn is_http_url(value: &str) -> bool {
    starts_with_ascii_case_insensitive(value, "http://")
        || starts_with_ascii_case_insensitive(value, "https://")
}

fn is_proxy_uri_delimiter(c: char) -> bool {
    c.is_whitespace() || matches!(c, '"' | '\'' | '<' | '>' | ')' | ']' | '}' | '`' | '|')
}

fn normalize_proxy_uri_text(value: &str) -> String {
    let trimmed = value.trim_matches(|c| matches!(c, ';' | ','));
    let mut normalized = if trimmed.contains("\\/") {
        trimmed.replace("\\/", "/")
    } else {
        trimmed.to_string()
    };
    if let Some(decoded) = decode_proxy_uri_percent_escapes(&normalized) {
        normalized = decoded;
    }
    if let Some(decoded) = decode_proxy_uri_js_hex_escapes(&normalized) {
        normalized = decoded;
    }
    if let Some(decoded) = decode_proxy_uri_json_escapes(&normalized) {
        normalized = decoded;
    }
    if let Some(decoded) = decode_proxy_uri_html_entities(&normalized) {
        normalized = decoded;
    }
    normalized
}

fn decode_proxy_uri_percent_escapes(value: &str) -> Option<String> {
    if !value.contains('%') {
        return None;
    }
    let bytes = value.as_bytes();
    let mut out = String::with_capacity(value.len());
    let mut cursor = 0;
    let mut changed = false;
    while cursor < bytes.len() {
        if cursor + 3 <= bytes.len() && bytes[cursor] == b'%' {
            if let Some(decoded) = parse_ascii_hex(&bytes[cursor + 1..cursor + 3])
                .and_then(decode_proxy_uri_escape_value)
            {
                out.push(decoded);
                cursor += 3;
                changed = true;
                continue;
            }
        }
        let ch = value[cursor..].chars().next()?;
        out.push(ch);
        cursor += ch.len_utf8();
    }
    changed.then_some(out)
}

fn decode_proxy_uri_js_hex_escapes(value: &str) -> Option<String> {
    if !value.contains("\\x") && !value.contains("\\X") {
        return None;
    }
    let bytes = value.as_bytes();
    let mut out = String::with_capacity(value.len());
    let mut cursor = 0;
    let mut changed = false;
    while cursor < bytes.len() {
        if cursor + 4 <= bytes.len()
            && bytes[cursor] == b'\\'
            && matches!(bytes[cursor + 1], b'x' | b'X')
        {
            if let Some(decoded) = parse_ascii_hex(&bytes[cursor + 2..cursor + 4])
                .and_then(decode_proxy_uri_escape_value)
            {
                out.push(decoded);
                cursor += 4;
                changed = true;
                continue;
            }
        }
        let ch = value[cursor..].chars().next()?;
        out.push(ch);
        cursor += ch.len_utf8();
    }
    changed.then_some(out)
}

fn decode_proxy_uri_html_entities(value: &str) -> Option<String> {
    if !has_proxy_uri_html_entity_hint(value) {
        return None;
    }
    let bytes = value.as_bytes();
    let mut out = String::with_capacity(value.len());
    let mut cursor = 0;
    let mut changed = false;
    while cursor < bytes.len() {
        if bytes[cursor] == b'&' {
            if let Some((decoded, len)) = decode_proxy_uri_named_entity(&bytes[cursor..]) {
                out.push(decoded);
                cursor += len;
                changed = true;
                continue;
            }
            if let Some((decoded, len)) = decode_proxy_uri_numeric_entity(&bytes[cursor..]) {
                out.push(decoded);
                cursor += len;
                changed = true;
                continue;
            }
        }
        let ch = value[cursor..].chars().next()?;
        out.push(ch);
        cursor += ch.len_utf8();
    }
    changed.then_some(out)
}

fn has_proxy_uri_html_entity_hint(value: &str) -> bool {
    let bytes = value.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        if bytes[cursor] != b'&' {
            cursor += 1;
            continue;
        }
        if bytes[cursor..].starts_with(b"&#")
            || PROXY_URI_NAMED_HTML_ENTITIES
                .iter()
                .any(|(entity, _)| bytes[cursor..].starts_with(entity))
        {
            return true;
        }
        cursor += 1;
    }
    false
}

fn decode_proxy_uri_named_entity(bytes: &[u8]) -> Option<(char, usize)> {
    for (entity, decoded) in PROXY_URI_NAMED_HTML_ENTITIES {
        if bytes.starts_with(entity) {
            return Some((decoded, entity.len()));
        }
    }
    None
}

fn decode_proxy_uri_numeric_entity(bytes: &[u8]) -> Option<(char, usize)> {
    if !bytes.starts_with(b"&#") {
        return None;
    }
    let end = bytes.iter().position(|byte| *byte == b';')?;
    if end <= 2 || end > 8 {
        return None;
    }
    let body = &bytes[2..end];
    let value = if body
        .first()
        .is_some_and(|prefix| matches!(prefix, b'x' | b'X'))
    {
        parse_ascii_hex(&body[1..])?
    } else {
        parse_ascii_decimal(body)?
    };
    let decoded = decode_proxy_uri_escape_value(value)?;
    Some((decoded, end + 1))
}

fn decode_proxy_uri_escape_value(value: u32) -> Option<char> {
    match value {
        0x3a => Some(':'),
        0x2f => Some('/'),
        0x40 => Some('@'),
        0x26 => Some('&'),
        0x23 => Some('#'),
        0x3f => Some('?'),
        0x3d => Some('='),
        _ => None,
    }
}

fn parse_ascii_hex(bytes: &[u8]) -> Option<u32> {
    if bytes.is_empty() {
        return None;
    }
    let mut value = 0u32;
    for byte in bytes {
        value = value.checked_mul(16)?;
        value = value.checked_add(match byte {
            b'0'..=b'9' => (byte - b'0') as u32,
            b'a'..=b'f' => (byte - b'a' + 10) as u32,
            b'A'..=b'F' => (byte - b'A' + 10) as u32,
            _ => return None,
        })?;
    }
    Some(value)
}

fn parse_ascii_decimal(bytes: &[u8]) -> Option<u32> {
    if bytes.is_empty() {
        return None;
    }
    let mut value = 0u32;
    for byte in bytes {
        if !byte.is_ascii_digit() {
            return None;
        }
        value = value.checked_mul(10)?;
        value = value.checked_add((byte - b'0') as u32)?;
    }
    Some(value)
}

fn decode_proxy_uri_json_escapes(value: &str) -> Option<String> {
    if !value.contains("\\u00") && !value.contains("\\U00") {
        return None;
    }
    let bytes = value.as_bytes();
    let mut out = String::with_capacity(value.len());
    let mut cursor = 0;
    let mut changed = false;
    while cursor < bytes.len() {
        if cursor + 6 <= bytes.len()
            && bytes[cursor] == b'\\'
            && matches!(bytes[cursor + 1], b'u' | b'U')
            && bytes[cursor + 2] == b'0'
            && bytes[cursor + 3] == b'0'
        {
            if let Some(decoded) =
                decode_proxy_uri_json_escape(bytes[cursor + 4], bytes[cursor + 5])
            {
                out.push(decoded);
                cursor += 6;
                changed = true;
                continue;
            }
        }
        let ch = value[cursor..].chars().next()?;
        out.push(ch);
        cursor += ch.len_utf8();
    }
    changed.then_some(out)
}

fn decode_proxy_uri_json_escape(high: u8, low: u8) -> Option<char> {
    match (high, low) {
        (b'2', b'f' | b'F') => Some('/'),
        (b'2', b'6') => Some('&'),
        (b'2', b'3') => Some('#'),
        (b'3', b'a' | b'A') => Some(':'),
        (b'3', b'f' | b'F') => Some('?'),
        (b'3', b'd' | b'D') => Some('='),
        _ => None,
    }
}

fn parse_ss_proxy(value: &str) -> Option<Map<String, Value>> {
    parse_ss_proxy_inner(value, true)
}

fn parse_ss_proxy_inner(value: &str, allow_base64_decode: bool) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let fragment = uri.fragment().unwrap_or("SS");
    let name = percent_decode(fragment);
    if uri.username().is_empty() {
        if !allow_base64_decode {
            return None;
        }
        let payload = value
            .trim_start_matches("ss://")
            .split(['?', '#'])
            .next()
            .unwrap_or_default();
        if payload.trim().is_empty() {
            return None;
        }
        let decoded = decode_base64_text(payload)?;
        if decoded.trim().is_empty() {
            return None;
        }
        let query = uri.query();
        let mut rebuilt = String::with_capacity(
            "ss://".len()
                + decoded.len()
                + query.map_or(0, |value| 1 + value.len())
                + 1
                + fragment.len(),
        );
        rebuilt.push_str("ss://");
        rebuilt.push_str(&decoded);
        if let Some(value) = query {
            rebuilt.push('?');
            rebuilt.push_str(value);
        }
        rebuilt.push('#');
        rebuilt.push_str(fragment);
        return parse_ss_proxy_inner(&rebuilt, false);
    }
    let (cipher, password) = parse_ss_credentials(uri.username(), uri.password())?;
    let mut proxy = Map::new();
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "SS" } else { &name }),
    );
    proxy.insert("type".into(), json!("ss"));
    proxy.insert("server".into(), json!(uri.host_str()?));
    proxy.insert("port".into(), json!(uri.port()?));
    proxy.insert("cipher".into(), json!(cipher));
    proxy.insert("password".into(), json!(password));
    proxy.insert("udp".into(), json!(true));
    if uri_query_bool_param(&uri, &["udp-over-tcp"]) || uri_query_exact_param(&uri, "uot", "1") {
        proxy.insert("udp-over-tcp".into(), json!(true));
    }
    insert_ss_plugin_param(
        &mut proxy,
        uri_query_param_value(&uri, &["plugin"]).as_deref(),
    );
    Some(proxy)
}

fn parse_ss_credentials(username: &str, password: Option<&str>) -> Option<(String, String)> {
    if let Some(password) = password {
        return Some((percent_decode(username), percent_decode(password)));
    }
    let decoded = decode_base64_text(&percent_decode(username))?;
    let (cipher, password) = decoded.split_once(':')?;
    if cipher.trim().is_empty() || password.is_empty() {
        return None;
    }
    Some((cipher.to_string(), password.to_string()))
}

fn insert_ss_plugin_param(proxy: &mut Map<String, Value>, value: Option<&str>) {
    let Some(value) = value
        .map(|value| value.trim())
        .filter(|value| !value.is_empty())
    else {
        return;
    };
    let mut parts = value
        .split(';')
        .map(str::trim)
        .filter(|part| !part.is_empty());
    let Some(plugin) = parts.next() else {
        return;
    };
    let mut raw_opts = HashMap::with_capacity(delimited_tail_capacity(value, b';'));
    for part in parts {
        if part.eq_ignore_ascii_case("tls") {
            raw_opts.insert("tls".to_string(), "true".to_string());
            continue;
        }
        let Some((key, value)) = part.split_once('=') else {
            continue;
        };
        let key = key.trim();
        let value = value.trim();
        if key.is_empty() || value.is_empty() {
            continue;
        }
        raw_opts.insert(key.to_string(), percent_decode(value));
    }
    if plugin.contains("v2ray-plugin") {
        insert_ss_v2ray_plugin_opts(proxy, &raw_opts);
        return;
    }
    if plugin.eq_ignore_ascii_case("shadow-tls") || plugin.eq_ignore_ascii_case("shadowtls") {
        insert_ss_shadow_tls_plugin_opts(proxy, &raw_opts);
        return;
    }
    if plugin.eq_ignore_ascii_case("gost-plugin") {
        insert_ss_gost_plugin_opts(proxy, &raw_opts);
        return;
    }
    if !matches!(plugin, "obfs-local" | "simple-obfs" | "obfs") {
        return;
    }
    insert_ss_obfs_plugin_opts(proxy, &raw_opts);
}

fn insert_ss_obfs_plugin_opts(proxy: &mut Map<String, Value>, raw_opts: &HashMap<String, String>) {
    let mut opts = Map::new();
    if let Some(mode) = raw_opts
        .get("obfs")
        .or_else(|| raw_opts.get("mode"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("mode".into(), json!(mode));
    }
    if let Some(host) = raw_opts
        .get("obfs-host")
        .or_else(|| raw_opts.get("host"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("host".into(), json!(host));
    }
    proxy.insert("plugin".into(), json!("obfs"));
    if !opts.is_empty() {
        proxy.insert("plugin-opts".into(), Value::Object(opts));
    }
}

fn insert_ss_shadow_tls_plugin_opts(
    proxy: &mut Map<String, Value>,
    raw_opts: &HashMap<String, String>,
) {
    let mut opts = Map::new();
    if let Some(host) = raw_opts
        .get("host")
        .or_else(|| raw_opts.get("sni"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("host".into(), json!(host));
    }
    if let Some(password) = raw_opts
        .get("password")
        .or_else(|| raw_opts.get("pwd"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("password".into(), json!(password));
    }
    if let Some(version) = raw_opts
        .get("version")
        .filter(|value| !value.is_empty())
        .and_then(|value| value.parse::<i64>().ok())
    {
        opts.insert("version".into(), json!(version));
    }
    if let Some(alpn) = raw_opts.get("alpn").filter(|value| !value.is_empty()) {
        if let Some(value) = csv_array_value(alpn) {
            opts.insert("alpn".into(), value);
        }
    }
    if raw_opts
        .get("skip-cert-verify")
        .or_else(|| raw_opts.get("allowInsecure"))
        .or_else(|| raw_opts.get("insecure"))
        .is_some_and(|value| value == "1" || value.eq_ignore_ascii_case("true"))
    {
        opts.insert("skip-cert-verify".into(), json!(true));
    }
    if let Some(fingerprint) = raw_opts
        .get("fingerprint")
        .filter(|value| !value.is_empty())
    {
        opts.insert("fingerprint".into(), json!(fingerprint));
    }
    if let Some(certificate) = raw_opts
        .get("certificate")
        .filter(|value| !value.is_empty())
    {
        opts.insert("certificate".into(), json!(certificate));
    }
    if let Some(private_key) = raw_opts
        .get("private-key")
        .or_else(|| raw_opts.get("private_key"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("private-key".into(), json!(private_key));
    }
    if let Some(client_fingerprint) = raw_opts
        .get("client-fingerprint")
        .or_else(|| raw_opts.get("client_fingerprint"))
        .or_else(|| raw_opts.get("fp"))
        .filter(|value| !value.is_empty())
    {
        proxy.insert("client-fingerprint".into(), json!(client_fingerprint));
    }
    proxy.insert("plugin".into(), json!("shadow-tls"));
    if !opts.is_empty() {
        proxy.insert("plugin-opts".into(), Value::Object(opts));
    }
}

fn insert_ss_gost_plugin_opts(proxy: &mut Map<String, Value>, raw_opts: &HashMap<String, String>) {
    let mut opts = Map::new();
    if let Some(mode) = raw_opts
        .get("mode")
        .or_else(|| raw_opts.get("obfs"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("mode".into(), json!(mode));
    }
    if let Some(host) = raw_opts
        .get("host")
        .or_else(|| raw_opts.get("obfs-host"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("host".into(), json!(host));
    }
    if let Some(path) = raw_opts.get("path").filter(|value| !value.is_empty()) {
        opts.insert("path".into(), json!(path));
    }
    if raw_opts
        .get("tls")
        .is_some_and(|value| value == "1" || value.eq_ignore_ascii_case("true"))
    {
        opts.insert("tls".into(), json!(true));
    }
    if raw_opts
        .get("mux")
        .is_some_and(|value| value == "1" || value.eq_ignore_ascii_case("true"))
    {
        opts.insert("mux".into(), json!(true));
    }
    if raw_opts
        .get("skip-cert-verify")
        .or_else(|| raw_opts.get("allowInsecure"))
        .or_else(|| raw_opts.get("insecure"))
        .is_some_and(|value| value == "1" || value.eq_ignore_ascii_case("true"))
    {
        opts.insert("skip-cert-verify".into(), json!(true));
    }
    if let Some(fingerprint) = raw_opts
        .get("fingerprint")
        .filter(|value| !value.is_empty())
    {
        opts.insert("fingerprint".into(), json!(fingerprint));
    }
    if let Some(certificate) = raw_opts
        .get("certificate")
        .filter(|value| !value.is_empty())
    {
        opts.insert("certificate".into(), json!(certificate));
    }
    if let Some(private_key) = raw_opts
        .get("private-key")
        .or_else(|| raw_opts.get("private_key"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("private-key".into(), json!(private_key));
    }
    insert_ss_plugin_headers(&mut opts, raw_opts);
    proxy.insert("plugin".into(), json!("gost-plugin"));
    if !opts.is_empty() {
        proxy.insert("plugin-opts".into(), Value::Object(opts));
    }
}

fn insert_ss_plugin_headers(opts: &mut Map<String, Value>, raw_opts: &HashMap<String, String>) {
    let mut headers = Map::new();
    if let Some(value) = raw_opts.get("headers").filter(|value| !value.is_empty()) {
        for item in value.split(['|', ',']) {
            let Some((key, value)) = item.split_once(':') else {
                continue;
            };
            let key = key.trim();
            let value = value.trim();
            if key.is_empty() || value.is_empty() {
                continue;
            }
            headers.insert(key.into(), json!(value));
        }
    }
    for (key, value) in raw_opts {
        let header_key = key
            .strip_prefix("header-")
            .or_else(|| key.strip_prefix("header."));
        let Some(header_key) = header_key else {
            continue;
        };
        let header_key = header_key.trim();
        let value = value.trim();
        if header_key.is_empty() || value.is_empty() {
            continue;
        }
        headers.insert(header_key.into(), json!(value));
    }
    if !headers.is_empty() {
        opts.insert("headers".into(), Value::Object(headers));
    }
}

fn insert_ss_v2ray_plugin_opts(proxy: &mut Map<String, Value>, raw_opts: &HashMap<String, String>) {
    let mut opts = Map::new();
    if let Some(mode) = raw_opts
        .get("mode")
        .or_else(|| raw_opts.get("obfs"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("mode".into(), json!(mode));
    }
    if let Some(host) = raw_opts
        .get("host")
        .or_else(|| raw_opts.get("obfs-host"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("host".into(), json!(host));
    }
    if let Some(path) = raw_opts.get("path").filter(|value| !value.is_empty()) {
        opts.insert("path".into(), json!(path));
    }
    if raw_opts
        .get("tls")
        .is_some_and(|value| value == "1" || value.eq_ignore_ascii_case("true"))
    {
        opts.insert("tls".into(), json!(true));
    }
    proxy.insert("plugin".into(), json!("v2ray-plugin"));
    if !opts.is_empty() {
        proxy.insert("plugin-opts".into(), Value::Object(opts));
    }
}

fn parse_ssr_proxy(value: &str) -> Option<Map<String, Value>> {
    let payload = value.trim_start_matches("ssr://");
    let decoded = decode_base64_text(payload)?;
    let (main, query) = decoded.split_once("/?").unwrap_or((&decoded, ""));
    let mut parts = main.splitn(6, ':');
    let server = parts.next()?.trim();
    let port = parts.next()?.parse::<i64>().ok()?;
    let protocol = parts.next()?.trim();
    let method = parts.next()?.trim();
    let obfs = parts.next()?.trim();
    let password = decode_ssr_value(parts.next()?)?;
    if server.is_empty()
        || protocol.is_empty()
        || method.is_empty()
        || obfs.is_empty()
        || password.is_empty()
    {
        return None;
    }
    let params = parse_ssr_query(query);
    let name = params
        .get("remarks")
        .filter(|value| !value.is_empty())
        .cloned()
        .unwrap_or_else(|| "SSR".to_string());
    let mut proxy = Map::new();
    proxy.insert("name".into(), json!(name));
    proxy.insert("type".into(), json!("ssr"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));
    proxy.insert("cipher".into(), json!(method));
    proxy.insert("password".into(), json!(password));
    proxy.insert("protocol".into(), json!(protocol));
    proxy.insert("obfs".into(), json!(obfs));
    proxy.insert("udp".into(), json!(true));
    if let Some(value) = params.get("protoparam").filter(|value| !value.is_empty()) {
        proxy.insert("protocol-param".into(), json!(value));
    }
    if let Some(value) = params.get("obfsparam").filter(|value| !value.is_empty()) {
        proxy.insert("obfs-param".into(), json!(value));
    }
    Some(proxy)
}

fn parse_ssr_query(query: &str) -> HashMap<String, String> {
    let mut params = HashMap::with_capacity(query_pair_capacity(query));
    for pair in query.split('&') {
        let (key, value) = pair.split_once('=').unwrap_or((pair, ""));
        if key.is_empty() || value.is_empty() {
            continue;
        }
        if let Some(decoded) = decode_ssr_value(value) {
            params.insert(key.to_string(), decoded);
        }
    }
    params
}

fn decode_ssr_value(value: &str) -> Option<String> {
    decode_base64_text(&percent_decode(value))
}

fn parse_tuic_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let user = percent_decode(uri.username());
    if user.is_empty() {
        return None;
    }
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("TUIC"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "TUIC" } else { &name }),
    );
    proxy.insert("type".into(), json!("tuic"));
    proxy.insert("server".into(), json!(uri.host_str()?));
    proxy.insert("port".into(), json!(port));
    proxy.insert("udp".into(), json!(true));
    if let Some(password) = uri.password().filter(|value| !value.is_empty()) {
        proxy.insert("uuid".into(), json!(user));
        proxy.insert("password".into(), json!(percent_decode(password)));
    } else {
        proxy.insert("token".into(), json!(user));
    }
    insert_uri_param(
        &mut proxy,
        &uri,
        "congestion-controller",
        &["congestion_control", "congestion-controller"],
    );
    insert_uri_param(
        &mut proxy,
        &uri,
        "udp-relay-mode",
        &["udp_relay_mode", "udp-relay-mode"],
    );
    insert_uri_param(&mut proxy, &uri, "fingerprint", &["fingerprint", "fp"]);
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "heartbeat-interval",
        &["heartbeat-interval", "heartbeat_interval"],
    );
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "request-timeout",
        &["request-timeout", "request_timeout"],
    );
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "max-open-streams",
        &["max-open-streams", "max_open_streams"],
    );
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "max-udp-relay-packet-size",
        &["max-udp-relay-packet-size", "max_udp_relay_packet_size"],
    );
    insert_uri_param(&mut proxy, &uri, "sni", &["sni"]);
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "disable-sni",
        &["disable_sni", "disable-sni"],
    );
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "skip-cert-verify",
        &[
            "skip-cert-verify",
            "skip_cert_verify",
            "allowInsecure",
            "allow_insecure",
            "insecure",
        ],
    );
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "reduce-rtt",
        &["reduce-rtt", "reduce_rtt"],
    );
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "udp-over-stream",
        &["udp-over-stream", "udp_over_stream"],
    );
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "udp-over-stream-version",
        &["udp-over-stream-version", "udp_over_stream_version"],
    );
    insert_uri_alpn_param(&mut proxy, &uri);
    Some(proxy)
}

fn parse_snell_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let psk = percent_decode(uri.username());
    if psk.is_empty() {
        return None;
    }
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("Snell"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "Snell" } else { &name }),
    );
    proxy.insert("type".into(), json!("snell"));
    proxy.insert("server".into(), json!(uri.host_str()?));
    proxy.insert("port".into(), json!(port));
    proxy.insert("psk".into(), json!(psk));

    insert_uri_int_param(&mut proxy, &uri, "version", &["version"]);

    let mut obfs_opts = Map::new();
    if let Some(mode) = uri_query_param_value(&uri, &["obfs", "mode"]) {
        obfs_opts.insert("mode".into(), json!(mode));
    }
    if let Some(host) = uri_query_param_value(&uri, &["obfs-host", "obfs_host", "host"]) {
        obfs_opts.insert("host".into(), json!(host));
    }
    if !obfs_opts.is_empty() {
        proxy.insert("obfs-opts".into(), Value::Object(obfs_opts));
    }
    Some(proxy)
}

fn parse_anytls_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let server = uri.host_str()?;
    let username = percent_decode(uri.username());
    if username.is_empty() {
        return None;
    }
    let password = uri
        .password()
        .filter(|value| !value.is_empty())
        .map(percent_decode)
        .unwrap_or_else(|| username.clone());
    let mut proxy = Map::new();
    let name = uri
        .fragment()
        .map(percent_decode)
        .filter(|name| !name.is_empty())
        .unwrap_or_else(|| format!("{server}:{port}"));
    proxy.insert("name".into(), json!(name));
    proxy.insert("type".into(), json!("anytls"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));
    proxy.insert("username".into(), json!(username));
    proxy.insert("password".into(), json!(password));
    proxy.insert("udp".into(), json!(true));
    if let Some(value) = uri_query_param_value(&uri, &["sni"]) {
        proxy.insert("sni".into(), json!(value));
    }
    if let Some(value) = uri_query_param_value(&uri, &["hpkp"]) {
        proxy.insert("fingerprint".into(), json!(value));
    }
    if uri_query_exact_param(&uri, "insecure", "1") {
        proxy.insert("skip-cert-verify".into(), json!(true));
    }
    Some(proxy)
}

fn parse_mierus_proxies(value: &str) -> Vec<Map<String, Value>> {
    let Ok(uri) = Url::parse(value) else {
        return Vec::new();
    };
    let Some(server) = uri.host_str().filter(|server| !server.is_empty()) else {
        return Vec::new();
    };
    let username = percent_decode(uri.username());
    let password = uri
        .password()
        .map(percent_decode)
        .unwrap_or_else(String::new);
    let query_capacity = uri.query().map(query_pair_capacity).unwrap_or(0);
    let mut ports = Vec::with_capacity(query_capacity);
    let mut protocols = Vec::with_capacity(query_capacity);
    let mut profile = None;
    let mut multiplexing = None;
    let mut handshake_mode = None;
    let mut traffic_pattern = None;
    for (key, value) in uri.query_pairs() {
        match key.as_ref() {
            "port" if !value.is_empty() => ports.push(value.into_owned()),
            "protocol" if !value.is_empty() => protocols.push(value.into_owned()),
            "profile" if !value.is_empty() => profile = Some(value.into_owned()),
            "multiplexing" if !value.is_empty() => multiplexing = Some(value.into_owned()),
            "handshake-mode" if !value.is_empty() => handshake_mode = Some(value.into_owned()),
            "traffic-pattern" if !value.is_empty() => traffic_pattern = Some(value.into_owned()),
            _ => {}
        }
    }
    if ports.is_empty() || ports.len() != protocols.len() {
        return Vec::new();
    }
    let fragment = uri
        .fragment()
        .map(percent_decode)
        .filter(|name| !name.is_empty());
    let base_name = fragment.or(profile).unwrap_or_else(|| server.to_string());
    ports
        .into_iter()
        .zip(protocols)
        .filter_map(|(port, protocol)| {
            let mut proxy = Map::new();
            proxy.insert(
                "name".into(),
                json!(format!("{base_name}:{port}/{protocol}")),
            );
            proxy.insert("type".into(), json!("mieru"));
            proxy.insert("server".into(), json!(server));
            proxy.insert("transport".into(), json!(protocol));
            proxy.insert("udp".into(), json!(true));
            proxy.insert("username".into(), json!(username));
            proxy.insert("password".into(), json!(password));
            if port.contains('-') {
                proxy.insert("port-range".into(), json!(port));
            } else {
                let port = port.parse::<i64>().ok()?;
                proxy.insert("port".into(), json!(port));
            }
            if let Some(value) = &multiplexing {
                proxy.insert("multiplexing".into(), json!(value));
            }
            if let Some(value) = &handshake_mode {
                proxy.insert("handshake-mode".into(), json!(value));
            }
            if let Some(value) = &traffic_pattern {
                proxy.insert("traffic-pattern".into(), json!(value));
            }
            Some(proxy)
        })
        .collect()
}

fn parse_socks_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("SOCKS5"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "SOCKS5" } else { &name }),
    );
    proxy.insert("type".into(), json!("socks5"));
    proxy.insert("server".into(), json!(uri.host_str()?));
    proxy.insert("port".into(), json!(port));
    insert_proxy_credentials(&mut proxy, &uri);
    if uri_query_bool_param(&uri, &["udp"]) {
        proxy.insert("udp".into(), json!(true));
    }
    Some(proxy)
}

fn parse_ssh_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let server = uri.host_str()?;
    let port = uri.port().unwrap_or(22);
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("SSH"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "SSH" } else { &name }),
    );
    proxy.insert("type".into(), json!("ssh"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));

    let username = percent_decode(uri.username());
    if username.is_empty() {
        insert_uri_param(&mut proxy, &uri, "username", &["username", "user"]);
    } else {
        proxy.insert("username".into(), json!(username));
    }
    if let Some(password) = uri.password().filter(|value| !value.is_empty()) {
        proxy.insert("password".into(), json!(percent_decode(password)));
    } else {
        insert_uri_param(&mut proxy, &uri, "password", &["password", "pass"]);
    }
    if !proxy.contains_key("username") {
        return None;
    }

    insert_uri_param(
        &mut proxy,
        &uri,
        "private-key",
        &["private-key", "privateKey", "private_key"],
    );
    insert_uri_param(
        &mut proxy,
        &uri,
        "private-key-passphrase",
        &[
            "private-key-passphrase",
            "privateKeyPassphrase",
            "private_key_passphrase",
        ],
    );
    insert_uri_csv_param(&mut proxy, &uri, "host-key", &["host-key", "hostKey"]);
    insert_uri_csv_param(
        &mut proxy,
        &uri,
        "host-key-algorithms",
        &[
            "host-key-algorithms",
            "hostKeyAlgorithms",
            "host_key_algorithms",
        ],
    );
    Some(proxy)
}

fn parse_masque_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let server = uri.host_str()?;
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("MASQUE"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "MASQUE" } else { &name }),
    );
    proxy.insert("type".into(), json!("masque"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));

    let private_key = percent_decode(uri.username());
    if !private_key.is_empty() {
        proxy.insert("private-key".into(), json!(private_key));
    } else {
        insert_uri_param(
            &mut proxy,
            &uri,
            "private-key",
            &["private-key", "privateKey", "private_key"],
        );
    }
    insert_uri_param(
        &mut proxy,
        &uri,
        "public-key",
        &["public-key", "publicKey", "public_key", "pubkey"],
    );
    insert_uri_param(&mut proxy, &uri, "ip", &["ip"]);
    insert_uri_param(&mut proxy, &uri, "ipv6", &["ipv6"]);
    insert_uri_param(&mut proxy, &uri, "uri", &["uri"]);
    insert_uri_param(&mut proxy, &uri, "sni", &["sni"]);
    insert_uri_param(&mut proxy, &uri, "network", &["network"]);
    insert_uri_param(
        &mut proxy,
        &uri,
        "congestion-controller",
        &[
            "congestion-controller",
            "congestion_controller",
            "congestionController",
        ],
    );
    insert_uri_param(
        &mut proxy,
        &uri,
        "bbr-profile",
        &["bbr-profile", "bbr_profile", "bbrProfile"],
    );
    insert_uri_int_param(&mut proxy, &uri, "mtu", &["mtu"]);
    insert_uri_int_param(&mut proxy, &uri, "cwnd", &["cwnd"]);
    insert_uri_bool_param(&mut proxy, &uri, "udp", &["udp"]);
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "skip-cert-verify",
        &["skip-cert-verify", "skip_cert_verify", "insecure"],
    );
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "remote-dns-resolve",
        &["remote-dns-resolve", "remote_dns_resolve"],
    );
    insert_uri_csv_param(&mut proxy, &uri, "dns", &["dns"]);
    Some(proxy)
}

fn parse_trusttunnel_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let server = uri.host_str()?;
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("TrustTunnel"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() {
            "TrustTunnel"
        } else {
            &name
        }),
    );
    proxy.insert("type".into(), json!("trusttunnel"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));
    insert_proxy_credentials(&mut proxy, &uri);
    insert_uri_alpn_param(&mut proxy, &uri);
    insert_uri_param(&mut proxy, &uri, "sni", &["sni"]);
    insert_uri_param(
        &mut proxy,
        &uri,
        "client-fingerprint",
        &[
            "client-fingerprint",
            "client_fingerprint",
            "clientFingerprint",
        ],
    );
    insert_uri_param(&mut proxy, &uri, "fingerprint", &["fingerprint", "hpkp"]);
    insert_uri_param(&mut proxy, &uri, "certificate", &["certificate", "cert"]);
    insert_uri_param(
        &mut proxy,
        &uri,
        "private-key",
        &["private-key", "privateKey", "private_key"],
    );
    insert_uri_param(
        &mut proxy,
        &uri,
        "congestion-controller",
        &[
            "congestion-controller",
            "congestion_controller",
            "congestionController",
        ],
    );
    insert_uri_param(
        &mut proxy,
        &uri,
        "bbr-profile",
        &["bbr-profile", "bbr_profile", "bbrProfile"],
    );
    insert_uri_bool_param(&mut proxy, &uri, "udp", &["udp"]);
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "health-check",
        &["health-check", "health_check", "healthCheck"],
    );
    insert_uri_bool_param(&mut proxy, &uri, "quic", &["quic"]);
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "skip-cert-verify",
        &["skip-cert-verify", "skip_cert_verify", "insecure"],
    );
    insert_uri_int_param(&mut proxy, &uri, "cwnd", &["cwnd"]);
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "max-connections",
        &["max-connections", "max_connections", "maxConnections"],
    );
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "min-streams",
        &["min-streams", "min_streams", "minStreams"],
    );
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "max-streams",
        &["max-streams", "max_streams", "maxStreams"],
    );
    Some(proxy)
}

fn parse_wireguard_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let server = uri.host_str()?;
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("WireGuard"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "WireGuard" } else { &name }),
    );
    proxy.insert("type".into(), json!("wireguard"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));

    let private_key = percent_decode(uri.username());
    if !private_key.is_empty() {
        proxy.insert("private-key".into(), json!(private_key));
    } else {
        insert_uri_param(&mut proxy, &uri, "private-key", &["private-key"]);
    }
    insert_uri_param(&mut proxy, &uri, "public-key", &["public-key", "pubkey"]);
    insert_uri_param(
        &mut proxy,
        &uri,
        "pre-shared-key",
        &["pre-shared-key", "preshared-key", "psk"],
    );
    insert_uri_param(&mut proxy, &uri, "ip", &["ip"]);
    insert_uri_param(&mut proxy, &uri, "ipv6", &["ipv6"]);
    insert_uri_param(&mut proxy, &uri, "reserved", &["reserved"]);
    insert_uri_bool_param(&mut proxy, &uri, "udp", &["udp"]);
    insert_uri_bool_param(
        &mut proxy,
        &uri,
        "remote-dns-resolve",
        &["remote-dns-resolve", "remote_dns_resolve"],
    );
    insert_uri_int_param(&mut proxy, &uri, "mtu", &["mtu"]);
    insert_uri_int_param(&mut proxy, &uri, "workers", &["workers"]);
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "persistent-keepalive",
        &["persistent-keepalive", "persistent_keepalive", "keepalive"],
    );
    insert_uri_int_param(
        &mut proxy,
        &uri,
        "refresh-server-ip-interval",
        &["refresh-server-ip-interval", "refresh_server_ip_interval"],
    );
    insert_uri_csv_param(
        &mut proxy,
        &uri,
        "allowed-ips",
        &["allowed-ips", "allowed_ips"],
    );
    insert_uri_csv_param(&mut proxy, &uri, "dns", &["dns"]);
    Some(proxy)
}

fn parse_http_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    if !matches!(uri.path(), "" | "/") {
        return None;
    }
    let server = uri.host_str()?;
    let mut proxy = Map::new();
    let name = uri
        .fragment()
        .map(percent_decode)
        .filter(|name| !name.is_empty())
        .unwrap_or_else(|| format!("{server}:{port}"));
    proxy.insert("name".into(), json!(name));
    proxy.insert("type".into(), json!("http"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));
    proxy.insert("skip-cert-verify".into(), json!(true));
    if uri.scheme().eq_ignore_ascii_case("https") {
        proxy.insert("tls".into(), json!(true));
    }
    insert_proxy_credentials(&mut proxy, &uri);
    Some(proxy)
}

fn insert_proxy_credentials(proxy: &mut Map<String, Value>, uri: &Url) {
    let username = percent_decode(uri.username());
    if username.is_empty() {
        return;
    }
    if let Some(password) = uri.password().filter(|value| !value.is_empty()) {
        proxy.insert("username".into(), json!(username));
        proxy.insert("password".into(), json!(percent_decode(password)));
        return;
    }
    if let Some((decoded_username, decoded_password)) = decode_userinfo_pair(&username) {
        proxy.insert("username".into(), json!(decoded_username));
        proxy.insert("password".into(), json!(decoded_password));
        return;
    }
    proxy.insert("username".into(), json!(username));
}

fn decode_userinfo_pair(value: &str) -> Option<(String, String)> {
    let decoded = decode_base64_text(value)?;
    let (username, password) = decoded.split_once(':')?;
    if username.is_empty() {
        return None;
    }
    Some((username.to_string(), password.to_string()))
}

fn parse_hysteria_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port()?;
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("Hysteria"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "Hysteria" } else { &name }),
    );
    proxy.insert("type".into(), json!("hysteria"));
    proxy.insert("server".into(), json!(uri.host_str()?));
    proxy.insert("port".into(), json!(port));
    insert_uri_param(
        &mut proxy,
        &uri,
        "auth_str",
        &["auth", "auth-str", "auth_str"],
    );
    insert_uri_param(&mut proxy, &uri, "protocol", &["protocol"]);
    insert_uri_param(&mut proxy, &uri, "up", &["up", "upmbps"]);
    insert_uri_param(&mut proxy, &uri, "down", &["down", "downmbps"]);
    insert_uri_param(&mut proxy, &uri, "ports", &["ports"]);
    insert_uri_param(&mut proxy, &uri, "sni", &["peer", "sni"]);
    insert_uri_param(&mut proxy, &uri, "obfs", &["obfs"]);
    insert_uri_param(&mut proxy, &uri, "obfs-protocol", &["obfs-protocol"]);
    insert_uri_alpn_param(&mut proxy, &uri);
    insert_uri_bool_param(&mut proxy, &uri, "skip-cert-verify", &["insecure"]);
    Some(proxy)
}

fn parse_hysteria2_proxy(value: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let port = uri.port().unwrap_or(443);
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or("Hysteria2"));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { "Hysteria2" } else { &name }),
    );
    proxy.insert("type".into(), json!("hysteria2"));
    proxy.insert("server".into(), json!(uri.host_str()?));
    proxy.insert("port".into(), json!(port));
    let user = percent_decode(uri.username());
    if !user.is_empty() {
        let password = uri
            .password()
            .map(percent_decode)
            .filter(|value| !value.is_empty())
            .map(|password| format!("{user}:{password}"))
            .unwrap_or(user);
        proxy.insert("password".into(), json!(password));
    }
    insert_uri_param(&mut proxy, &uri, "obfs", &["obfs"]);
    insert_uri_param(&mut proxy, &uri, "obfs-password", &["obfs-password"]);
    insert_uri_param(&mut proxy, &uri, "sni", &["sni"]);
    insert_uri_param(
        &mut proxy,
        &uri,
        "fingerprint",
        &["pinSHA256", "fingerprint"],
    );
    insert_uri_param(&mut proxy, &uri, "up", &["up"]);
    insert_uri_param(&mut proxy, &uri, "down", &["down"]);
    insert_uri_param(&mut proxy, &uri, "ports", &["ports", "mport"]);
    insert_uri_param(
        &mut proxy,
        &uri,
        "hop-interval",
        &["hop-interval", "hop_interval"],
    );
    insert_uri_alpn_param(&mut proxy, &uri);
    insert_uri_bool_param(&mut proxy, &uri, "skip-cert-verify", &["insecure"]);
    Some(proxy)
}

fn insert_param(
    proxy: &mut Map<String, Value>,
    params: &HashMap<String, String>,
    output_key: &str,
    input_keys: &[&str],
) {
    if let Some(value) = input_keys
        .iter()
        .filter_map(|key| params.get(*key))
        .find(|value| !value.is_empty())
    {
        proxy.insert(output_key.into(), json!(value));
    }
}

fn insert_bool_param(
    proxy: &mut Map<String, Value>,
    params: &HashMap<String, String>,
    output_key: &str,
    input_keys: &[&str],
) {
    if input_keys
        .iter()
        .filter_map(|key| params.get(*key))
        .any(|value| value == "1" || value.eq_ignore_ascii_case("true"))
    {
        proxy.insert(output_key.into(), json!(true));
    }
}

fn uri_query_param_value(uri: &Url, input_keys: &[&str]) -> Option<String> {
    uri_query_param_cow(uri, input_keys).map(Cow::into_owned)
}

fn uri_query_param_cow<'a>(uri: &'a Url, input_keys: &[&str]) -> Option<Cow<'a, str>> {
    let mut best = None::<(usize, Cow<'a, str>)>;
    for (key, value) in uri.query_pairs() {
        if value.is_empty() {
            continue;
        }
        let Some(priority) = uri_query_key_priority(key.as_ref(), input_keys) else {
            continue;
        };
        if priority == 0 {
            return Some(value);
        }
        if best
            .as_ref()
            .is_none_or(|(best_priority, _)| priority < *best_priority)
        {
            best = Some((priority, value));
        }
    }
    best.map(|(_, value)| value)
}

fn uri_query_bool_param(uri: &Url, input_keys: &[&str]) -> bool {
    uri.query_pairs().any(|(key, value)| {
        uri_query_key_priority(key.as_ref(), input_keys).is_some()
            && (value == "1" || value.eq_ignore_ascii_case("true"))
    })
}

fn uri_query_key_priority(key: &str, input_keys: &[&str]) -> Option<usize> {
    let mut index = 0;
    while index < input_keys.len() {
        if key == input_keys[index] {
            return Some(index);
        }
        index += 1;
    }
    None
}

fn uri_query_exact_param(uri: &Url, input_key: &str, expected_value: &str) -> bool {
    uri.query_pairs()
        .any(|(key, value)| key.as_ref() == input_key && value == expected_value)
}

fn query_pair_capacity(query: &str) -> usize {
    if query.is_empty() {
        return 0;
    }
    1 + query
        .as_bytes()
        .iter()
        .filter(|byte| **byte == b'&')
        .count()
}

fn delimited_tail_capacity(value: &str, delimiter: u8) -> usize {
    value
        .as_bytes()
        .iter()
        .filter(|byte| **byte == delimiter)
        .count()
}

fn csv_item_capacity(value: &str) -> usize {
    if value.is_empty() {
        return 0;
    }
    1 + value
        .as_bytes()
        .iter()
        .filter(|byte| **byte == b',')
        .count()
}

fn uri_query_params_map(uri: &Url) -> HashMap<String, String> {
    let capacity = uri.query().map(query_pair_capacity).unwrap_or(0);
    let mut params = HashMap::with_capacity(capacity);
    for (key, value) in uri.query_pairs() {
        if key.is_empty() {
            continue;
        }
        params.insert(key.into_owned(), value.into_owned());
    }
    params
}

fn insert_uri_param(
    proxy: &mut Map<String, Value>,
    uri: &Url,
    output_key: &str,
    input_keys: &[&str],
) {
    if let Some(value) = uri_query_param_value(uri, input_keys) {
        proxy.insert(output_key.into(), json!(value));
    }
}

fn insert_uri_bool_param(
    proxy: &mut Map<String, Value>,
    uri: &Url,
    output_key: &str,
    input_keys: &[&str],
) {
    if uri_query_bool_param(uri, input_keys) {
        proxy.insert(output_key.into(), json!(true));
    }
}

fn insert_uri_int_param(
    proxy: &mut Map<String, Value>,
    uri: &Url,
    output_key: &str,
    input_keys: &[&str],
) {
    if let Some(value) =
        uri_query_param_value(uri, input_keys).and_then(|value| value.parse::<i64>().ok())
    {
        proxy.insert(output_key.into(), json!(value));
    }
}

fn insert_uri_alpn_param(proxy: &mut Map<String, Value>, uri: &Url) {
    let Some(value) = uri_query_param_value(uri, &["alpn"]) else {
        return;
    };
    insert_alpn_value(proxy, &value);
}

fn insert_uri_csv_param(
    proxy: &mut Map<String, Value>,
    uri: &Url,
    output_key: &str,
    input_keys: &[&str],
) {
    let Some(value) = uri_query_param_value(uri, input_keys) else {
        return;
    };
    insert_csv_value(proxy, output_key, &value);
}

fn insert_csv_value(proxy: &mut Map<String, Value>, output_key: &str, value: &str) {
    if let Some(value) = csv_array_value(value) {
        proxy.insert(output_key.into(), value);
    }
}

fn insert_alpn_param(proxy: &mut Map<String, Value>, params: &HashMap<String, String>) {
    let Some(value) = params.get("alpn").filter(|value| !value.is_empty()) else {
        return;
    };
    insert_alpn_value(proxy, value);
}

fn insert_alpn_value(proxy: &mut Map<String, Value>, value: &str) {
    if let Some(value) = csv_array_value(value) {
        proxy.insert("alpn".into(), value);
    }
}

fn csv_array_value(value: &str) -> Option<Value> {
    let mut items = Vec::with_capacity(csv_item_capacity(value));
    for item in value.split(',').map(str::trim) {
        if !item.is_empty() {
            items.push(Value::String(item.to_string()));
        }
    }
    (!items.is_empty()).then_some(Value::Array(items))
}

fn string_values_array_value(values: &[Value]) -> Option<Value> {
    let mut items = Vec::with_capacity(values.len());
    for value in values.iter().filter_map(string_value) {
        if !value.trim().is_empty() {
            items.push(Value::String(value));
        }
    }
    (!items.is_empty()).then_some(Value::Array(items))
}

fn ends_with_tls_ignore_ascii_case(value: &str) -> bool {
    let bytes = value.as_bytes();
    bytes.len() >= 3 && bytes[bytes.len() - 3..].eq_ignore_ascii_case(b"tls")
}

fn parse_vmess_proxy(value: &str) -> Option<Map<String, Value>> {
    let payload = value.trim_start_matches("vmess://");
    let Some(decoded) = decode_base64_text(payload) else {
        return parse_vmess_aead_proxy(value);
    };
    let data = serde_json::from_str::<Value>(&decoded).ok()?;
    let object = data.as_object()?;
    let port = parse_port(object.get("port")?)?;
    let uuid = string_value(object.get("id")?)?;
    let server = string_value(object.get("add")?)?;
    let mut proxy = Map::new();
    let name = object
        .get("ps")
        .and_then(string_value)
        .filter(|v| !v.is_empty())
        .unwrap_or_else(|| "VMess".to_string());
    proxy.insert("name".into(), json!(name));
    proxy.insert("type".into(), json!("vmess"));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));
    proxy.insert("uuid".into(), json!(uuid));
    proxy.insert("udp".into(), json!(true));
    proxy.insert("xudp".into(), json!(true));
    proxy.insert(
        "alterId".into(),
        json!(object.get("aid").and_then(parse_port).unwrap_or(0)),
    );
    proxy.insert(
        "cipher".into(),
        json!(object
            .get("scy")
            .and_then(string_value)
            .filter(|v| !v.is_empty())
            .unwrap_or_else(|| "auto".to_string())),
    );
    if let Some(net) = object
        .get("net")
        .and_then(string_value)
        .filter(|v| !v.is_empty())
    {
        let network = normalize_vmess_network(net, object);
        proxy.insert("network".into(), json!(network));
    }
    if let Some(tls) = object
        .get("tls")
        .and_then(string_value)
        .filter(|v| !v.is_empty())
    {
        proxy.insert("tls".into(), json!(ends_with_tls_ignore_ascii_case(&tls)));
        if let Some(alpn) = object
            .get("alpn")
            .and_then(string_value)
            .filter(|value| !value.is_empty())
        {
            insert_alpn_value(&mut proxy, &alpn);
        }
        if let Some(fingerprint) = object_string_param(object, &["fp", "client-fingerprint"]) {
            proxy.insert("client-fingerprint".into(), json!(fingerprint));
        }
        if object_bool_param(object, &["allowInsecure", "insecure", "skip-cert-verify"]) {
            proxy.insert("skip-cert-verify".into(), json!(true));
        }
    }
    if let Some(sni) = object
        .get("sni")
        .and_then(string_value)
        .or_else(|| object.get("host").and_then(string_value))
        .filter(|v| !v.is_empty())
    {
        proxy.insert("servername".into(), json!(sni));
    }
    insert_vmess_transport_opts(&mut proxy, object);
    Some(proxy)
}

fn parse_vmess_aead_proxy(value: &str) -> Option<Map<String, Value>> {
    let mut proxy = parse_user_info_proxy(value, "vmess")?;
    proxy.insert("alterId".into(), json!(0));
    let uri = Url::parse(value).ok()?;
    let cipher = uri_query_param_value(&uri, &["encryption"]).unwrap_or_else(|| "auto".to_string());
    proxy.insert("cipher".into(), json!(cipher));
    insert_v_share_packet_encoding_value(
        &mut proxy,
        uri_query_param_value(&uri, &["packetEncoding"]).as_deref(),
    );
    Some(proxy)
}

fn object_string_param(object: &Map<String, Value>, keys: &[&str]) -> Option<String> {
    keys.iter()
        .filter_map(|key| object.get(*key))
        .filter_map(string_value)
        .find(|value| !value.is_empty())
}

fn object_bool_param(object: &Map<String, Value>, keys: &[&str]) -> bool {
    keys.iter()
        .filter_map(|key| object.get(*key))
        .any(value_bool)
}

fn value_bool(value: &Value) -> bool {
    if let Some(value) = value.as_bool() {
        return value;
    }
    if let Some(value) = value.as_i64() {
        return value != 0;
    }
    value
        .as_str()
        .is_some_and(|value| value == "1" || value.eq_ignore_ascii_case("true"))
}

fn insert_vmess_transport_opts(proxy: &mut Map<String, Value>, object: &Map<String, Value>) {
    let mut params = HashMap::with_capacity(4);
    if let Some(network) = object
        .get("net")
        .and_then(string_value)
        .filter(|value| !value.is_empty())
    {
        params.insert("type".to_string(), normalize_vmess_network(network, object));
    }
    if let Some(path) = object
        .get("path")
        .and_then(string_value)
        .filter(|value| !value.is_empty())
    {
        if params
            .get("type")
            .is_some_and(|network| network.eq_ignore_ascii_case("grpc"))
        {
            params.insert("serviceName".to_string(), path.clone());
        }
        params.insert("path".to_string(), path);
    }
    if let Some(host) = object
        .get("host")
        .and_then(string_value)
        .filter(|value| !value.is_empty())
    {
        params.insert("host".to_string(), host);
    }
    if !params.contains_key("path")
        && params.get("type").is_some_and(|network| {
            network.eq_ignore_ascii_case("ws") || network.eq_ignore_ascii_case("httpupgrade")
        })
    {
        params.insert("path".to_string(), "/".to_string());
    }
    insert_ws_opts(proxy, &params);
    insert_grpc_opts(proxy, &params);
    insert_http_opts(proxy, &params);
    insert_h2_opts(proxy, &params);
}

fn normalize_vmess_network(network: String, object: &Map<String, Value>) -> String {
    if object
        .get("type")
        .and_then(string_value)
        .is_some_and(|value| value.eq_ignore_ascii_case("http"))
    {
        "http".to_string()
    } else if network.eq_ignore_ascii_case("http") {
        "h2".to_string()
    } else if is_ascii_lowercase_text(&network) {
        network
    } else {
        network.to_ascii_lowercase()
    }
}

fn normalize_user_info_network(params: &HashMap<String, String>) -> Option<Cow<'_, str>> {
    let network = params
        .get("type")
        .map(|value| value.as_str())
        .filter(|value| !value.is_empty());
    let has_http_header = params
        .get("headerType")
        .or_else(|| params.get("header-type"))
        .is_some_and(|value| value.eq_ignore_ascii_case("http"));
    let Some(network) = network else {
        return has_http_header.then_some(Cow::Borrowed("http"));
    };
    if has_http_header && network.eq_ignore_ascii_case("tcp") {
        Some(Cow::Borrowed("http"))
    } else if network.eq_ignore_ascii_case("http") {
        Some(Cow::Borrowed("h2"))
    } else if is_ascii_lowercase_text(network) {
        Some(Cow::Borrowed(network))
    } else {
        Some(Cow::Owned(network.to_ascii_lowercase()))
    }
}

fn is_ascii_lowercase_text(value: &str) -> bool {
    value.bytes().all(|byte| !byte.is_ascii_uppercase())
}

fn is_user_info_tls(proxy_type: &str, params: &HashMap<String, String>) -> bool {
    if proxy_type == "trojan" {
        return true;
    }
    params.get("security").is_some_and(|security| {
        ends_with_tls_ignore_ascii_case(security) || security.eq_ignore_ascii_case("reality")
    })
}

fn parse_user_info_proxy(value: &str, proxy_type: &str) -> Option<Map<String, Value>> {
    let uri = Url::parse(value).ok()?;
    let (server, port) = user_info_server_port(&uri, proxy_type)?;
    let user_info = percent_decode(uri.username());
    if user_info.is_empty() {
        return None;
    }
    let mut proxy = Map::new();
    let name = percent_decode(uri.fragment().unwrap_or(proxy_type));
    proxy.insert(
        "name".into(),
        json!(if name.is_empty() { proxy_type } else { &name }),
    );
    proxy.insert("type".into(), json!(proxy_type));
    proxy.insert("server".into(), json!(server));
    proxy.insert("port".into(), json!(port));
    if proxy_type == "trojan" || proxy_type == "hysteria2" {
        proxy.insert("password".into(), json!(user_info));
    } else {
        proxy.insert("uuid".into(), json!(user_info));
    }
    let mut params = uri_query_params_map(&uri);
    let tls_enabled = is_user_info_tls(proxy_type, &params);
    if let Some(sni) = params
        .get("sni")
        .or_else(|| params.get("peer"))
        .or_else(|| params.get("host"))
        .filter(|v| !v.is_empty())
    {
        proxy.insert("sni".into(), json!(sni));
        proxy.insert("servername".into(), json!(sni));
    }
    let updated_type = if let Some(network) = normalize_user_info_network(&params) {
        let network_text = network.as_ref();
        let should_update_type = params
            .get("type")
            .is_none_or(|value| !value.eq_ignore_ascii_case(network_text));
        let updated_type = should_update_type.then(|| network_text.to_string());
        proxy.insert("network".into(), json!(network_text));
        updated_type
    } else {
        None
    };
    if let Some(updated_type) = updated_type {
        params.insert("type".to_string(), updated_type);
    }
    if params
        .get("security")
        .is_some_and(|security| !security.is_empty())
    {
        proxy.insert("tls".into(), json!(tls_enabled));
    }
    insert_ws_opts(&mut proxy, &params);
    insert_grpc_opts(&mut proxy, &params);
    insert_http_opts(&mut proxy, &params);
    insert_h2_opts(&mut proxy, &params);
    insert_xhttp_opts(&mut proxy, &params);
    insert_param(&mut proxy, &params, "flow", &["flow"]);
    insert_param(
        &mut proxy,
        &params,
        "client-fingerprint",
        &["fp", "fingerprint", "client-fingerprint"],
    );
    if let Some(pcs) = params.get("pcs").filter(|value| !value.is_empty()) {
        if !proxy.contains_key("fingerprint") {
            proxy.insert("fingerprint".into(), json!(pcs));
        }
    }
    if tls_enabled && !proxy.contains_key("client-fingerprint") {
        proxy.insert("client-fingerprint".into(), json!("chrome"));
    }
    insert_alpn_param(&mut proxy, &params);
    insert_reality_opts(&mut proxy, &params);
    insert_bool_param(
        &mut proxy,
        &params,
        "skip-cert-verify",
        &[
            "allowInsecure",
            "allow_insecure",
            "insecure",
            "skip-cert-verify",
            "skip_cert_verify",
            "skipCertVerify",
        ],
    );
    if proxy_type == "vless" {
        insert_v_share_packet_encoding(&mut proxy, &params);
    }
    Some(proxy)
}

fn user_info_server_port(uri: &Url, proxy_type: &str) -> Option<(String, u16)> {
    if let Some(port) = uri.port() {
        return Some((uri.host_str()?.to_string(), port));
    }
    if proxy_type != "vless" {
        return None;
    }
    let decoded = decode_base64_text(uri.host_str()?)?;
    let (server, port) = decoded.rsplit_once(':')?;
    if server.is_empty() {
        return None;
    }
    Some((server.to_string(), port.parse::<u16>().ok()?))
}

fn insert_v_share_packet_encoding(
    proxy: &mut Map<String, Value>,
    params: &HashMap<String, String>,
) {
    insert_v_share_packet_encoding_value(proxy, params.get("packetEncoding").map(String::as_str));
}

fn insert_v_share_packet_encoding_value(
    proxy: &mut Map<String, Value>,
    packet_encoding: Option<&str>,
) {
    proxy.insert("udp".into(), json!(true));
    match packet_encoding {
        Some("none") => {}
        Some("packet") => {
            proxy.insert("packet-addr".into(), json!(true));
        }
        _ => {
            proxy.insert("xudp".into(), json!(true));
        }
    }
}

fn insert_ws_opts(proxy: &mut Map<String, Value>, params: &HashMap<String, String>) {
    let Some(network) = params.get("type").filter(|network| {
        network.eq_ignore_ascii_case("ws") || network.eq_ignore_ascii_case("httpupgrade")
    }) else {
        return;
    };
    let mut opts = Map::new();
    if let Some(path) = params.get("path").filter(|value| !value.is_empty()) {
        let path = insert_ws_early_data_opts(&mut opts, network, params, Some(path))
            .unwrap_or_else(|| path.to_string());
        opts.insert("path".into(), json!(path));
    } else {
        insert_ws_early_data_opts(&mut opts, network, params, None);
    }
    let mut headers = Map::new();
    if let Some(host) = params.get("host").filter(|value| !value.is_empty()) {
        headers.insert("Host".into(), json!(host));
    }
    if !headers.is_empty() {
        opts.insert("headers".into(), Value::Object(headers));
    }
    if !opts.is_empty() {
        proxy.insert("ws-opts".into(), Value::Object(opts));
    }
}

fn insert_ws_early_data_opts(
    opts: &mut Map<String, Value>,
    network: &str,
    params: &HashMap<String, String>,
    path: Option<&str>,
) -> Option<String> {
    let mut early_data = params.get("ed").and_then(|value| value.parse::<i64>().ok());
    let mut header = params.get("eh").filter(|value| !value.is_empty()).cloned();
    let mut cleaned_path = path.map(str::to_string);

    if let Some(path) = path {
        if let Some((base, query)) = path.split_once('?') {
            let mut kept = Vec::with_capacity(query_pair_capacity(query));
            let mut path_early_data = None;
            let mut path_header = None;
            for pair in query.split('&') {
                let (key, value) = pair.split_once('=').unwrap_or((pair, ""));
                if key == "ed" && path_early_data.is_none() {
                    if let Ok(max_early_data) = percent_decode(value).parse::<i64>() {
                        path_early_data = Some(max_early_data);
                        continue;
                    }
                } else if key == "ed" {
                    continue;
                }
                if key == "eh" && path_header.is_none() && !value.is_empty() {
                    path_header = Some(percent_decode(value));
                }
                kept.push(pair);
            }
            if let Some(value) = path_early_data {
                early_data = Some(value);
                if kept.is_empty() {
                    cleaned_path = Some(base.to_string());
                } else {
                    cleaned_path = Some(format!("{base}?{}", kept.join("&")));
                }
            }
            if let Some(value) = path_header {
                header = Some(value);
            }
        }
    }

    if let Some(early_data) = early_data {
        if network.eq_ignore_ascii_case("ws") {
            opts.insert("max-early-data".into(), json!(early_data));
            opts.insert(
                "early-data-header-name".into(),
                json!("Sec-WebSocket-Protocol"),
            );
        } else if network.eq_ignore_ascii_case("httpupgrade") {
            opts.insert("v2ray-http-upgrade-fast-open".into(), json!(true));
        }
    }
    if let Some(value) = header {
        opts.insert("early-data-header-name".into(), json!(value));
    }
    cleaned_path
}

fn insert_grpc_opts(proxy: &mut Map<String, Value>, params: &HashMap<String, String>) {
    if !params
        .get("type")
        .is_some_and(|network| network.eq_ignore_ascii_case("grpc"))
    {
        return;
    }
    let Some(service_name) = params
        .get("serviceName")
        .or_else(|| params.get("service-name"))
        .or_else(|| params.get("grpc-service-name"))
        .filter(|value| !value.is_empty())
    else {
        return;
    };
    let mut opts = Map::new();
    opts.insert("grpc-service-name".into(), json!(service_name));
    proxy.insert("grpc-opts".into(), Value::Object(opts));
}

fn insert_http_opts(proxy: &mut Map<String, Value>, params: &HashMap<String, String>) {
    if !params
        .get("type")
        .is_some_and(|network| network.eq_ignore_ascii_case("http"))
    {
        return;
    }
    let mut opts = Map::new();
    if let Some(method) = params.get("method").filter(|value| !value.is_empty()) {
        opts.insert("method".into(), json!(method));
    }
    opts.insert(
        "path".into(),
        json!([params
            .get("path")
            .filter(|value| !value.is_empty())
            .map(String::as_str)
            .unwrap_or("/")]),
    );
    let mut headers = Map::new();
    if let Some(host) = params.get("host").filter(|value| !value.is_empty()) {
        headers.insert("Host".into(), json!([host]));
    }
    opts.insert("headers".into(), Value::Object(headers));
    proxy.insert("http-opts".into(), Value::Object(opts));
}

fn insert_h2_opts(proxy: &mut Map<String, Value>, params: &HashMap<String, String>) {
    if !params
        .get("type")
        .is_some_and(|network| network.eq_ignore_ascii_case("h2"))
    {
        return;
    }
    let mut opts = Map::new();
    opts.insert(
        "path".into(),
        json!(params
            .get("path")
            .filter(|value| !value.is_empty())
            .map(String::as_str)
            .unwrap_or("/")),
    );
    if let Some(host) = params.get("host").filter(|value| !value.is_empty()) {
        opts.insert("host".into(), json!([host]));
    }
    proxy.insert("h2-opts".into(), Value::Object(opts));
}

fn insert_xhttp_opts(proxy: &mut Map<String, Value>, params: &HashMap<String, String>) {
    if !params
        .get("type")
        .is_some_and(|network| network.eq_ignore_ascii_case("xhttp"))
    {
        return;
    }
    let mut opts = Map::new();
    insert_param(&mut opts, params, "path", &["path"]);
    insert_param(&mut opts, params, "host", &["host"]);
    insert_param(&mut opts, params, "mode", &["mode"]);
    proxy.insert("xhttp-opts".into(), Value::Object(opts));
}

fn insert_reality_opts(proxy: &mut Map<String, Value>, params: &HashMap<String, String>) {
    let mut opts = Map::new();
    if let Some(public_key) = params
        .get("pbk")
        .or_else(|| params.get("public-key"))
        .filter(|value| !value.is_empty())
    {
        opts.insert("public-key".into(), json!(public_key));
    }
    if let Some(short_id) = params
        .get("sid")
        .or_else(|| params.get("short-id"))
        .filter(|value| is_valid_reality_short_id(value))
    {
        opts.insert("short-id".into(), json!(short_id));
    }
    if !opts.is_empty() {
        proxy.insert("reality-opts".into(), Value::Object(opts));
    }
}

fn normalize_proxy(mut proxy: Map<String, Value>) -> Option<Map<String, Value>> {
    let name = string_value(proxy.get("name")?)?;
    let proxy_type = string_value(proxy.get("type")?)?;
    let server = string_value(proxy.get("server")?)?;
    let port = proxy.get("port").and_then(parse_port);
    let port_range = proxy
        .get("port-range")
        .and_then(string_value)
        .filter(|value| !value.trim().is_empty());
    if name.trim().is_empty()
        || proxy_type.trim().is_empty()
        || is_unsupported_generic_proxy_list_type(&proxy_type)
        || server.trim().is_empty()
        || server.contains(' ')
        || server.contains('\n')
        || port.is_some_and(|port| port <= 0)
        || (port.is_none() && port_range.is_none())
    {
        return None;
    }
    proxy.insert("name".into(), json!(name));
    proxy.insert("type".into(), json!(proxy_type));
    proxy.insert("server".into(), json!(server));
    if let Some(port) = port {
        proxy.insert("port".into(), json!(port));
    }
    if let Some(port_range) = port_range {
        proxy.insert("port-range".into(), json!(port_range));
    }
    normalize_ss_cipher(&mut proxy);
    sanitize_reality_opts(&mut proxy);
    Some(proxy)
}

fn normalize_ss_cipher(proxy: &mut Map<String, Value>) {
    if proxy
        .get("type")
        .and_then(string_value)
        .is_some_and(|proxy_type| proxy_type.eq_ignore_ascii_case("ss"))
        && proxy
            .get("cipher")
            .and_then(string_value)
            .is_some_and(|cipher| cipher.eq_ignore_ascii_case("chacha20-poly1305"))
    {
        proxy.insert("cipher".into(), json!("chacha20-ietf-poly1305"));
    }
}

fn sanitize_reality_opts(proxy: &mut Map<String, Value>) {
    let Some(opts) = proxy.get_mut("reality-opts").and_then(Value::as_object_mut) else {
        return;
    };
    if let Some(public_key) = opts.get("public-key").and_then(string_value) {
        if let Some(public_key) = normalize_reality_public_key(&public_key) {
            opts.insert("public-key".into(), json!(public_key));
        } else {
            proxy.remove("reality-opts");
            return;
        }
    }
    let short_id = opts.get("short-id").and_then(string_value);
    if let Some(short_id) = short_id {
        if is_valid_reality_short_id(&short_id) {
            opts.insert("short-id".into(), json!(short_id));
        } else {
            opts.remove("short-id");
        }
    }
    if opts.is_empty() {
        proxy.remove("reality-opts");
    }
}

fn normalize_reality_public_key(value: &str) -> Option<String> {
    let normalized = if value.contains('%') {
        percent_decode(value)
    } else {
        value.trim().to_string()
    };
    match URL_SAFE_NO_PAD.decode(normalized.as_bytes()) {
        Ok(decoded) if decoded.len() == 32 => Some(normalized),
        _ => None,
    }
}

fn is_valid_reality_short_id(value: &str) -> bool {
    let len = value.len();
    len <= 16 && len.is_multiple_of(2) && value.bytes().all(|byte| byte.is_ascii_hexdigit())
}

fn string_value(value: &Value) -> Option<String> {
    match value {
        Value::String(value) => Some(value.clone()),
        Value::Number(value) => Some(value.to_string()),
        Value::Bool(value) => Some(value.to_string()),
        _ => None,
    }
}

fn scalar_text_value(value: &Value) -> Option<Cow<'_, str>> {
    match value {
        Value::String(value) => Some(Cow::Borrowed(value.as_str())),
        Value::Number(value) => Some(Cow::Owned(value.to_string())),
        Value::Bool(value) => Some(Cow::Owned(value.to_string())),
        _ => None,
    }
}

fn parse_port(value: &Value) -> Option<i64> {
    match value {
        Value::Number(value) => value.as_i64(),
        Value::String(value) => value.parse::<i64>().ok(),
        _ => None,
    }
}

fn extract_existing_dated_proxies(
    text: Option<&str>,
    history_timeout_hours: i64,
    now_day_number: i64,
    cleanup_expired: bool,
) -> Vec<DatedProxy> {
    let Some(text) = text.filter(|text| !text.trim().is_empty()) else {
        return Vec::new();
    };
    let Ok(value) = serde_yaml_ng::from_str::<Value>(text) else {
        return Vec::new();
    };
    let Some(raw_proxies) = value.get("proxies").and_then(Value::as_array) else {
        return Vec::new();
    };
    let mut group_by_proxy_name =
        HashMap::<String, ExistingProxyGroup>::with_capacity(raw_proxies.len());
    let mut source_by_proxy_name = HashMap::<String, String>::with_capacity(raw_proxies.len());
    if let Some(groups) = value.get("proxy-groups").and_then(Value::as_array) {
        for group in groups.iter().filter_map(Value::as_object) {
            let Some(group_name) = group.get("name").and_then(scalar_text_value) else {
                continue;
            };
            let Some(names) = group.get("proxies").and_then(Value::as_array) else {
                continue;
            };
            let group_name = group_name.as_ref();
            if is_free_nodes_treasure_group(group_name) {
                for name in names.iter().filter_map(string_value) {
                    group_by_proxy_name
                        .entry(name)
                        .or_insert(ExistingProxyGroup::Treasure);
                }
            } else if let Some(source_label) = source_label_from_group_name(group_name) {
                for name in names.iter().filter_map(string_value) {
                    source_by_proxy_name.insert(name, source_label.clone());
                }
            } else {
                let date_token = date_token_from_label(group_name);
                if date_token > 0 {
                    for name in names.iter().filter_map(string_value) {
                        group_by_proxy_name.insert(name, ExistingProxyGroup::Date(date_token));
                    }
                }
            }
        }
    }
    let mut result = Vec::<DatedProxy>::with_capacity(raw_proxies.len());
    for proxy in raw_proxies.iter().filter_map(Value::as_object) {
        let Some(normalized) = normalize_proxy(proxy.clone()) else {
            continue;
        };
        let name = normalized
            .get("name")
            .and_then(string_value)
            .unwrap_or_default();
        let (date_token, date_label) =
            existing_proxy_group_label(group_by_proxy_name.get(&name).copied(), name.as_str());
        let source_label = source_by_proxy_name.get(&name).cloned();
        let item = DatedProxy {
            proxy: normalized,
            date_token,
            date_label,
            source_id: None,
            source_label,
        };
        if cleanup_expired
            && !should_keep_existing_proxy(&item, history_timeout_hours, now_day_number)
        {
            continue;
        }
        result.push(item);
    }
    result
}

fn existing_proxy_group_label(group: Option<ExistingProxyGroup>, name: &str) -> (i64, String) {
    match group {
        Some(ExistingProxyGroup::Date(token)) => (token, date_label_from_token(token)),
        Some(ExistingProxyGroup::Treasure) => (0, FREE_NODES_TREASURE_GROUP_NAME.to_string()),
        None => match date_token_from_text(name) {
            Some(token) => (token, date_label_from_token(token)),
            None => (0, FREE_NODES_HISTORY_GROUP_NAME.to_string()),
        },
    }
}

fn should_keep_existing_proxy(
    item: &DatedProxy,
    history_timeout_hours: i64,
    now_day_number: i64,
) -> bool {
    if item.date_token <= 0 {
        return true;
    }
    let Some(day_number) = day_number_from_token(item.date_token) else {
        return true;
    };
    let stale_from = day_number + 1;
    let keep_days = ((history_timeout_hours.max(1) + 23) / 24).max(1);
    now_day_number - stale_from <= keep_days
}

fn deduplicate_and_name(proxies: Vec<DatedProxy>) -> Vec<DatedProxy> {
    let candidate_count = proxies.len();
    let mut seen = HashSet::<String>::with_capacity(candidate_count);
    let mut used_names = HashSet::<String>::with_capacity(candidate_count);
    let mut next_name_suffixes = HashMap::<String, usize>::with_capacity(candidate_count);
    let mut result = Vec::<DatedProxy>::with_capacity(candidate_count);
    for dated in proxies {
        let mut proxy = dated.proxy;
        let mut key = proxy_fingerprint(&proxy);
        let source_identity = dated
            .source_id
            .as_deref()
            .filter(|value| !value.trim().is_empty())
            .or_else(|| {
                dated
                    .source_label
                    .as_deref()
                    .filter(|value| !value.trim().is_empty())
            })
            .unwrap_or_default();
        key.push('\0');
        key.push_str(source_identity);
        if !seen.insert(key) {
            continue;
        }
        let name = proxy
            .get("name")
            .and_then(scalar_text_value)
            .filter(|v| !v.trim().is_empty())
            .unwrap_or_else(|| {
                let proxy_type = proxy.get("type").and_then(scalar_text_value);
                let server = proxy.get("server").and_then(scalar_text_value);
                Cow::Owned(format!(
                    "{}-{}",
                    proxy_type.as_deref().unwrap_or_default(),
                    server.as_deref().unwrap_or_default()
                ))
            });
        let name = unique_name(name.as_ref(), &mut used_names, &mut next_name_suffixes);
        proxy.insert("name".into(), json!(name));
        let date_label = normalize_date_group_label(&dated.date_label);
        result.push(DatedProxy {
            proxy,
            date_label,
            date_token: dated.date_token,
            source_id: dated.source_id,
            source_label: dated.source_label,
        });
    }
    result
}

fn proxy_fingerprint(proxy: &Map<String, Value>) -> String {
    let mut fingerprint = String::new();
    for (index, key) in PROXY_FINGERPRINT_KEYS.iter().enumerate() {
        if index > 0 {
            fingerprint.push('|');
        }
        if let Some(value) = proxy.get(*key).and_then(scalar_text_value) {
            push_ascii_lowercase(&mut fingerprint, value.as_ref());
        }
    }
    fingerprint
}

fn push_ascii_lowercase(out: &mut String, value: &str) {
    if value.is_ascii() {
        out.reserve(value.len());
        for byte in value.bytes() {
            out.push(byte.to_ascii_lowercase() as char);
        }
        return;
    }
    out.extend(value.chars().map(|c| c.to_ascii_lowercase()));
}

fn unique_name(
    name: &str,
    used_names: &mut HashSet<String>,
    next_name_suffixes: &mut HashMap<String, usize>,
) -> String {
    let base_name = clean_proxy_base_name(name);
    let mut base_key = String::with_capacity(base_name.len());
    push_ascii_lowercase(&mut base_key, base_name.as_ref());
    if used_names.insert(base_key.clone()) {
        return base_name.into_owned();
    }
    let base_name = base_name.into_owned();
    let next_index = next_name_suffixes.entry(base_key).or_insert(1);
    let mut candidate = String::with_capacity(base_name.len() + 4);
    loop {
        candidate.clear();
        candidate.push_str(&base_name);
        candidate.push(' ');
        let _ = write!(&mut candidate, "{}", *next_index);
        *next_index += 1;
        let mut candidate_key = String::with_capacity(candidate.len());
        push_ascii_lowercase(&mut candidate_key, &candidate);
        if used_names.insert(candidate_key) {
            return candidate;
        }
    }
}

fn clean_proxy_base_name(name: &str) -> Cow<'_, str> {
    let trimmed = name.trim();
    if trimmed.is_empty() {
        return Cow::Borrowed("proxy");
    }
    if !trimmed.contains(['\r', '\n']) {
        return Cow::Borrowed(trimmed);
    }
    let mut cleaned = String::with_capacity(trimmed.len());
    for ch in trimmed.chars() {
        match ch {
            '\r' | '\n' => cleaned.push(' '),
            _ => cleaned.push(ch),
        }
    }
    Cow::Owned(cleaned)
}

fn build_clash_yaml(
    proxies: &[DatedProxy],
    today_token: i64,
    auto_prefer: bool,
) -> Result<String, String> {
    let candidate_count = proxies.len();
    let mut normalized_proxies = Vec::<Value>::with_capacity(candidate_count);
    let mut proxy_names = Vec::<String>::with_capacity(candidate_count);
    let mut date_proxy_names = HashMap::<i64, Vec<String>>::with_capacity(candidate_count);
    let mut source_proxy_names = HashMap::<String, Vec<String>>::with_capacity(candidate_count);
    let mut treasure_proxy_names = Vec::<String>::with_capacity(1);

    for item in proxies {
        normalized_proxies.push(Value::Object(item.proxy.clone()));
        let Some(name) = item.proxy.get("name").and_then(string_value) else {
            continue;
        };
        proxy_names.push(name.clone());
        if is_free_nodes_treasure_group(&item.date_label) {
            treasure_proxy_names.push(name);
            continue;
        }
        if item.date_token > 0 {
            date_proxy_names
                .entry(item.date_token)
                .or_default()
                .push(name.clone());
        }
        if let Some(source_label) = item
            .source_label
            .as_deref()
            .map(str::trim)
            .filter(|label| !label.is_empty())
        {
            source_proxy_names
                .entry(source_label.to_string())
                .or_default()
                .push(name);
        }
    }

    let mut date_tokens = date_proxy_names.keys().copied().collect::<Vec<_>>();
    date_tokens.sort_unstable_by(|a, b| b.cmp(a));
    if today_token > 0 {
        if let Some(position) = date_tokens.iter().position(|token| *token == today_token) {
            date_tokens.rotate_left(position);
        }
    }
    let mut source_labels = source_proxy_names.keys().cloned().collect::<Vec<_>>();
    source_labels.sort_unstable();
    let main_group_proxies =
        if auto_prefer && (!date_tokens.is_empty() || !treasure_proxy_names.is_empty()) {
            let mut names = Vec::<String>::with_capacity(
                date_tokens.len() + usize::from(!treasure_proxy_names.is_empty()),
            );
            names.extend(
                date_tokens
                    .iter()
                    .map(|token| date_label_from_token(*token)),
            );
            if !treasure_proxy_names.is_empty() {
                names.push(FREE_NODES_TREASURE_GROUP_NAME.to_string());
            }
            names
        } else if auto_prefer && !source_labels.is_empty() {
            let mut names = Vec::<String>::with_capacity(source_labels.len());
            names.extend(
                source_labels
                    .iter()
                    .map(|label| format!("{FREE_NODES_SOURCE_GROUP_PREFIX}{label}")),
            );
            names
        } else {
            proxy_names.clone()
        };

    let mut global_proxies = Vec::<String>::with_capacity(
        candidate_count
            + date_tokens.len()
            + source_labels.len()
            + 2
            + usize::from(!treasure_proxy_names.is_empty()),
    );
    global_proxies.push(FREE_NODES_GROUP_NAME.to_string());
    if !treasure_proxy_names.is_empty() {
        global_proxies.push(FREE_NODES_TREASURE_GROUP_NAME.to_string());
    }
    global_proxies.extend(
        date_tokens
            .iter()
            .map(|token| date_label_from_token(*token)),
    );
    global_proxies.extend(
        source_labels
            .iter()
            .map(|label| format!("{FREE_NODES_SOURCE_GROUP_PREFIX}{label}")),
    );
    global_proxies.extend(proxy_names.iter().cloned());
    global_proxies.push("DIRECT".to_string());

    let mut groups = Vec::<Value>::with_capacity(
        2 + date_tokens.len() + source_labels.len() + usize::from(!treasure_proxy_names.is_empty()),
    );
    groups.push(json!({
        "name": FREE_NODES_GROUP_NAME,
        "type": "url-test",
        "hidden": true,
        "proxies": main_group_proxies,
        "url": DEFAULT_TEST_URL,
        "interval": 300,
        "timeout": 5000,
        "lazy": false
    }));
    if !treasure_proxy_names.is_empty() {
        groups.push(json!({
            "name": FREE_NODES_TREASURE_GROUP_NAME,
            "type": "url-test",
            "hidden": false,
            "proxies": treasure_proxy_names,
            "url": DEFAULT_TEST_URL,
            "interval": 300,
            "timeout": 5000,
            "lazy": false
        }));
    }
    for token in &date_tokens {
        let label = date_label_from_token(*token);
        let names = date_proxy_names.remove(token).unwrap_or_default();
        groups.push(json!({
            "name": label,
            "type": "url-test",
            "hidden": true,
            "proxies": names,
            "url": DEFAULT_TEST_URL,
            "interval": 300,
            "timeout": 5000,
            "lazy": false
        }));
    }
    for label in &source_labels {
        let group_label = format!("{FREE_NODES_SOURCE_GROUP_PREFIX}{label}");
        let names = source_proxy_names
            .remove(label.as_str())
            .unwrap_or_default();
        groups.push(json!({
            "name": group_label,
            "type": "url-test",
            "hidden": false,
            "proxies": names,
            "url": DEFAULT_TEST_URL,
            "interval": 300,
            "timeout": 5000,
            "lazy": false
        }));
    }
    groups.push(json!({
        "name": "GLOBAL",
        "type": "select",
        "hidden": false,
        "proxies": global_proxies
    }));

    let value = json!({
        "mixed-port": DEFAULT_MIXED_PORT,
        "allow-lan": false,
        "mode": "rule",
        "log-level": "info",
        "unified-delay": true,
        "proxies": normalized_proxies,
        "proxy-groups": groups,
        "rules": [format!("MATCH,{FREE_NODES_GROUP_NAME}")]
    });
    serde_yaml_ng::to_string(&value).map_err(|e| format!("free nodes yaml: {e}"))
}

fn discover_urls(text: &str, base_url: &str) -> Vec<String> {
    if let Some(urls) = discover_github_api_urls(text, base_url) {
        let mut result = Vec::<String>::with_capacity(urls.len());
        let mut index = DiscoveredUrlIndex::with_capacity(urls.len());
        for url in urls {
            insert_ordered_discovered_url(&mut result, &mut index, url, None);
        }
        return result;
    }
    let mut result = Vec::<String>::with_capacity(DISCOVERY_URL_INITIAL_CAPACITY);
    let mut index = DiscoveredUrlIndex::with_capacity(DISCOVERY_URL_INITIAL_CAPACITY);
    let base = Url::parse(base_url).ok();
    add_contextual_discovered_urls(text, &mut result, &mut index, base.as_ref());
    add_absolute_discovered_urls(text, &mut result, &mut index);
    add_base64_discovered_urls(text, &mut result, &mut index, base.as_ref());
    result
}

fn add_contextual_discovered_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    if has_subscription_param_hint(text) {
        add_subscription_urls_from_deep_links(text, result, index, base);
    }
    if has_discovery_attribute_hint(text) {
        add_attribute_discovered_urls(text, result, index, base);
    }
    if has_meta_refresh_hint(text) {
        add_meta_refresh_url_values(text, result, index, base);
    }
    if has_quoted_literal_hint(text) {
        add_relative_config_string_values(text, result, index, base);
    }
    if has_html_entity_quoted_literal_hint(text) {
        add_html_entity_quoted_relative_config_string_values(text, result, index, base);
    }
    if has_yaml_url_field_hint(text) {
        add_yaml_config_url_values(text, result, index, base);
    }
    if has_markdown_link_hint(text) {
        add_markdown_config_links(text, result, index, base);
    }
}

fn add_absolute_discovered_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
) {
    for_each_absolute_url(text, |url| {
        insert_ordered_discovered_url(result, index, url, None);
    });
    if has_escaped_absolute_url_hint(text) {
        add_escaped_absolute_urls(text, result, index);
    }
    if has_json_unicode_absolute_url_hint(text) {
        add_json_unicode_absolute_urls(text, result, index);
    }
    if has_html_entity_absolute_url_hint(text) {
        add_html_entity_absolute_urls(text, result, index);
    }
    if has_percent_encoded_absolute_url_hint(text) {
        add_percent_encoded_absolute_urls(text, result, index);
    }
}

fn add_base64_discovered_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    let mut decoded_count = 0;
    let mut decoded_storage = DecodedCandidateStorage::default();
    while cursor < bytes.len() && decoded_count < DECODED_CANDIDATE_LIMIT {
        while cursor < bytes.len() && !is_base64_byte(bytes[cursor]) {
            cursor += 1;
        }
        let start = cursor;
        while cursor < bytes.len() && is_base64_byte(bytes[cursor]) {
            cursor += 1;
        }
        let token = &text[start..cursor];
        if token.len() < EMBEDDED_BASE64_MIN_LEN || token.len() > EMBEDDED_BASE64_MAX_LEN {
            continue;
        }
        let Some(decoded) = decode_base64_text(token) else {
            continue;
        };
        if !has_discoverable_url_payload_hint(&decoded) {
            continue;
        }
        let mut accepted = false;
        decoded_storage.insert_and_visit(text, decoded, |decoded| {
            let before = result.len();
            add_contextual_discovered_urls(decoded, result, index, base);
            add_absolute_discovered_urls(decoded, result, index);
            accepted = result.len() > before;
        });
        if accepted {
            decoded_count += 1;
        }
    }
}

fn has_discoverable_url_payload_hint(text: &str) -> bool {
    has_direct_absolute_url_hint(text)
        || has_escaped_absolute_url_hint(text)
        || has_json_unicode_absolute_url_hint(text)
        || has_html_entity_absolute_url_hint(text)
        || has_percent_encoded_absolute_url_hint(text)
        || has_subscription_param_hint(text)
        || has_discovery_attribute_hint(text)
        || has_meta_refresh_hint(text)
        || has_quoted_literal_hint(text)
        || has_html_entity_quoted_literal_hint(text)
        || has_yaml_url_field_hint(text)
        || has_markdown_link_hint(text)
}

fn has_direct_absolute_url_hint(text: &str) -> bool {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        if absolute_url_prefix_at(bytes, cursor) {
            return true;
        }
        cursor += 1;
    }
    false
}

fn has_escaped_absolute_url_hint(text: &str) -> bool {
    text.contains(r":\/\/") || text.contains(r"\/\/")
}

fn has_json_unicode_absolute_url_hint(text: &str) -> bool {
    contains_ascii_case_insensitive(text, r"\u002f")
        && (contains_ascii_case_insensitive(text, r":\u002f")
            || contains_ascii_case_insensitive(text, r"\u003a"))
}

fn has_html_entity_absolute_url_hint(text: &str) -> bool {
    text.contains("&#")
        || (contains_ascii_case_insensitive(text, "&colon;")
            && contains_ascii_case_insensitive(text, "&sol;"))
}

fn has_percent_encoded_absolute_url_hint(text: &str) -> bool {
    contains_ascii_case_insensitive(text, "%3a%2f%2f")
}

fn has_subscription_param_hint(text: &str) -> bool {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        if subscription_url_param_key_at(bytes, cursor).is_some() {
            return true;
        }
        cursor += 1;
    }
    false
}

const DISCOVERY_ATTRIBUTE_HINTS: [&str; 6] = [
    "href",
    "data-",
    "downloadurl",
    "download-url",
    "download_url",
    "html_url",
];

fn has_discovery_attribute_hint(text: &str) -> bool {
    contains_any_ascii_case_insensitive(text, &DISCOVERY_ATTRIBUTE_HINTS)
        || has_value_attribute_discovery_hint(text)
}

fn has_value_attribute_discovery_hint(text: &str) -> bool {
    contains_ascii_case_insensitive(text, "value")
        && (contains_ascii_case_insensitive(text, "subscribe")
            || contains_ascii_case_insensitive(text, "subscription")
            || contains_ascii_case_insensitive(text, "clash")
            || contains_ascii_case_insensitive(text, "v2ray")
            || text.contains("订阅")
            || text.contains("节点"))
}

fn has_meta_refresh_hint(text: &str) -> bool {
    contains_ascii_case_insensitive(text, "refresh")
        && contains_ascii_case_insensitive(text, "content")
}

fn has_quoted_literal_hint(text: &str) -> bool {
    text.as_bytes()
        .iter()
        .any(|byte| is_discovery_string_literal_quote(*byte))
}

fn has_html_entity_quoted_literal_hint(text: &str) -> bool {
    contains_ascii_case_insensitive(text, "&quot;")
        || contains_ascii_case_insensitive(text, "&#39;")
        || contains_ascii_case_insensitive(text, "&#x27;")
}

fn has_markdown_link_hint(text: &str) -> bool {
    text.contains("](") || text.contains("]:")
}

fn has_yaml_url_field_hint(text: &str) -> bool {
    contains_ascii_case_insensitive(text, "url:")
}

fn insert_ordered_discovered_url(
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    value: String,
    base: Option<&Url>,
) {
    let url = if starts_with_ascii_case_insensitive(&value, "http://")
        || starts_with_ascii_case_insensitive(&value, "https://")
    {
        Some(value)
    } else {
        base.and_then(|base| base.join(&value).ok().map(|url| url.to_string()))
    };
    if let Some(url) = url {
        let normalized = normalize_url(&url);
        if normalized.is_empty() {
            return;
        }
        let canonical = canonical_fetch_key(&normalized);
        if index.insert(result, &canonical) {
            result.push(canonical);
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct DiscoveredUrlFingerprint {
    hash: u64,
    len: usize,
}

#[derive(Debug)]
enum DiscoveredUrlBucket {
    One(usize),
    Many(Vec<usize>),
}

#[derive(Debug, Default)]
#[frb(ignore)]
struct DiscoveredUrlIndex {
    buckets: HashMap<DiscoveredUrlFingerprint, DiscoveredUrlBucket>,
}

impl DiscoveredUrlIndex {
    fn with_capacity(capacity: usize) -> Self {
        Self {
            buckets: HashMap::with_capacity(capacity),
        }
    }

    #[cfg(test)]
    fn capacity(&self) -> usize {
        self.buckets.capacity()
    }

    fn insert(&mut self, urls: &[String], value: &str) -> bool {
        self.insert_with_fingerprint(urls, value, discovered_url_fingerprint(value))
    }

    fn insert_with_fingerprint(
        &mut self,
        urls: &[String],
        value: &str,
        fingerprint: DiscoveredUrlFingerprint,
    ) -> bool {
        let next_index = urls.len();
        match self.buckets.get_mut(&fingerprint) {
            Some(DiscoveredUrlBucket::One(index)) => {
                if urls.get(*index).is_some_and(|url| url == value) {
                    false
                } else {
                    let first_index = *index;
                    self.buckets.insert(
                        fingerprint,
                        DiscoveredUrlBucket::Many(vec![first_index, next_index]),
                    );
                    true
                }
            }
            Some(DiscoveredUrlBucket::Many(indices)) => {
                if indices
                    .iter()
                    .any(|index| urls.get(*index).is_some_and(|url| url == value))
                {
                    false
                } else {
                    indices.push(next_index);
                    true
                }
            }
            None => {
                self.buckets
                    .insert(fingerprint, DiscoveredUrlBucket::One(next_index));
                true
            }
        }
    }
}

fn discovered_url_fingerprint(value: &str) -> DiscoveredUrlFingerprint {
    DiscoveredUrlFingerprint {
        hash: stable_discovered_url_hash(value.as_bytes()),
        len: value.len(),
    }
}

fn stable_discovered_url_hash(bytes: &[u8]) -> u64 {
    let mut hash = 0xcbf2_9ce4_8422_2325u64;
    for byte in bytes {
        hash ^= u64::from(*byte);
        hash = hash.wrapping_mul(0x0000_0100_0000_01b3);
    }
    hash
}

#[cfg(test)]
fn insert_discovered_urls_with_forced_fingerprint_for_testing<const N: usize>(
    values: [&str; N],
) -> Vec<String> {
    let mut result = Vec::<String>::new();
    let mut index = DiscoveredUrlIndex::default();
    let fingerprint = DiscoveredUrlFingerprint { hash: 7, len: 7 };
    for value in values {
        if index.insert_with_fingerprint(&result, value, fingerprint) {
            result.push(value.to_string());
        }
    }
    result
}

fn add_subscription_urls_from_deep_links(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        let Some(key_len) = subscription_url_param_key_at(bytes, cursor) else {
            cursor += 1;
            continue;
        };
        let start = cursor + key_len;
        let end = find_subscription_url_param_end(text, start);
        if start < end {
            let decoded = percent_decode(&text[start..end])
                .replace("\\/", "/")
                .replace("&amp;", "&");
            insert_subscription_url_param_value(&decoded, result, index, base);
        }
        cursor = end.saturating_add(1);
    }
}

fn insert_subscription_url_param_value(
    value: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    let normalized = normalize_url(value);
    if is_subscription_url_param_value_candidate(&normalized) {
        insert_ordered_discovered_url(result, index, normalized, base);
        return;
    }
    let Some(decoded) = decode_base64_text(value.trim()) else {
        return;
    };
    let normalized = normalize_url(&decoded);
    if is_subscription_url_param_value_candidate(&normalized) {
        insert_ordered_discovered_url(result, index, normalized, base);
    }
}

fn is_subscription_url_param_value_candidate(value: &str) -> bool {
    starts_with_ascii_case_insensitive(value, "http://")
        || starts_with_ascii_case_insensitive(value, "https://")
        || is_relative_config_candidate(value)
}

fn add_json_unicode_absolute_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
) {
    let mut cursor = 0;
    while cursor < text.len() {
        if !json_unicode_absolute_url_at(text, cursor) {
            cursor += 1;
            continue;
        }
        let end = find_json_unicode_url_end(text, cursor);
        if let Some(decoded) = decode_proxy_uri_json_escapes(&text[cursor..end]) {
            let normalized = normalize_url(&decoded);
            if starts_with_ascii_case_insensitive(&normalized, "http://")
                || starts_with_ascii_case_insensitive(&normalized, "https://")
            {
                insert_ordered_discovered_url(result, index, normalized, None);
            }
        }
        cursor = end.saturating_add(1);
    }
}

fn json_unicode_absolute_url_at(text: &str, index: usize) -> bool {
    let bytes = &text.as_bytes()[index..];
    if !matches!(bytes.first(), Some(b'h' | b'H')) {
        return false;
    }
    let https_slash = br"https:\u002f\u002f";
    let http_slash = br"http:\u002f\u002f";
    let https_colon = br"https\u003a\u002f\u002f";
    let http_colon = br"http\u003a\u002f\u002f";
    (bytes.len() >= https_slash.len()
        && bytes[..https_slash.len()].eq_ignore_ascii_case(https_slash))
        || (bytes.len() >= http_slash.len()
            && bytes[..http_slash.len()].eq_ignore_ascii_case(http_slash))
        || (bytes.len() >= https_colon.len()
            && bytes[..https_colon.len()].eq_ignore_ascii_case(https_colon))
        || (bytes.len() >= http_colon.len()
            && bytes[..http_colon.len()].eq_ignore_ascii_case(http_colon))
}

fn find_json_unicode_url_end(text: &str, start: usize) -> usize {
    text[start..]
        .char_indices()
        .find_map(|(offset, c)| {
            (c.is_whitespace() || matches!(c, '"' | '\'' | '<' | '>' | ')' | ']' | '}' | '`' | '&'))
                .then_some(start + offset)
        })
        .unwrap_or(text.len())
}

fn add_html_entity_absolute_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
) {
    let mut cursor = 0;
    while cursor < text.len() {
        if !html_entity_absolute_url_at(text, cursor) {
            cursor += 1;
            continue;
        }
        let end = find_html_entity_url_end(text, cursor);
        if let Some(decoded) = decode_proxy_uri_html_entities(&text[cursor..end]) {
            let normalized = normalize_url(&decoded);
            if starts_with_ascii_case_insensitive(&normalized, "http://")
                || starts_with_ascii_case_insensitive(&normalized, "https://")
            {
                insert_ordered_discovered_url(result, index, normalized, None);
            }
        }
        cursor = end.saturating_add(1);
    }
}

fn html_entity_absolute_url_at(text: &str, index: usize) -> bool {
    let bytes = &text.as_bytes()[index..];
    if !matches!(bytes.first(), Some(b'h' | b'H')) {
        return false;
    }
    if starts_with_ascii_bytes(bytes, b"https:") {
        return html_entity_slashes_at(&bytes[b"https:".len()..]);
    }
    if starts_with_ascii_bytes(bytes, b"http:") {
        return html_entity_slashes_at(&bytes[b"http:".len()..]);
    }
    if starts_with_ascii_bytes(bytes, b"https") {
        return html_entity_colon_slashes_at(&bytes[b"https".len()..]);
    }
    starts_with_ascii_bytes(bytes, b"http") && html_entity_colon_slashes_at(&bytes[b"http".len()..])
}

fn html_entity_colon_slashes_at(bytes: &[u8]) -> bool {
    if starts_with_ascii_bytes(bytes, b"&#x3a;") {
        return html_entity_slashes_at(&bytes[b"&#x3a;".len()..]);
    }
    if starts_with_ascii_bytes(bytes, b"&#58;") {
        return html_entity_slashes_at(&bytes[b"&#58;".len()..]);
    }
    starts_with_ascii_bytes(bytes, b"&colon;") && html_entity_slashes_at(&bytes[b"&colon;".len()..])
}

fn html_entity_slashes_at(bytes: &[u8]) -> bool {
    starts_with_ascii_bytes(bytes, b"&#x2f;&#x2f;")
        || starts_with_ascii_bytes(bytes, b"&#47;&#47;")
        || starts_with_ascii_bytes(bytes, b"&sol;&sol;")
}

fn starts_with_ascii_bytes(bytes: &[u8], prefix: &[u8]) -> bool {
    bytes.len() >= prefix.len() && bytes[..prefix.len()].eq_ignore_ascii_case(prefix)
}

fn find_html_entity_url_end(text: &str, start: usize) -> usize {
    text[start..]
        .char_indices()
        .find_map(|(offset, c)| {
            (c.is_whitespace() || matches!(c, '"' | '\'' | '<' | '>' | ')' | ']' | '}' | '`'))
                .then_some(start + offset)
        })
        .unwrap_or(text.len())
}

fn add_percent_encoded_absolute_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
) {
    let mut cursor = 0;
    while cursor < text.len() {
        if !percent_encoded_absolute_url_at(text, cursor) {
            cursor += 1;
            continue;
        }
        let start = cursor;
        let end = find_percent_encoded_url_end(text, start);
        let decoded = percent_decode(&text[start..end])
            .replace("\\/", "/")
            .replace("&amp;", "&");
        let normalized = normalize_url(&decoded);
        if starts_with_ascii_case_insensitive(&normalized, "http://")
            || starts_with_ascii_case_insensitive(&normalized, "https://")
        {
            insert_ordered_discovered_url(result, index, normalized, None);
        }
        cursor = end.saturating_add(1);
    }
}

fn percent_encoded_absolute_url_at(text: &str, index: usize) -> bool {
    let bytes = &text.as_bytes()[index..];
    if !matches!(bytes.first(), Some(b'h' | b'H')) {
        return false;
    }
    let https = b"https%3a%2f%2f";
    let http = b"http%3a%2f%2f";
    (bytes.len() >= https.len() && bytes[..https.len()].eq_ignore_ascii_case(https))
        || (bytes.len() >= http.len() && bytes[..http.len()].eq_ignore_ascii_case(http))
}

fn find_percent_encoded_url_end(text: &str, start: usize) -> usize {
    text[start..]
        .char_indices()
        .find_map(|(offset, c)| {
            (c.is_whitespace() || matches!(c, '"' | '\'' | '<' | '>' | ')' | ']' | '}' | '`' | '&'))
                .then_some(start + offset)
        })
        .unwrap_or(text.len())
}

fn subscription_url_param_key_at(bytes: &[u8], index: usize) -> Option<usize> {
    if !is_subscription_url_param_boundary(bytes, index) {
        return None;
    }
    SUBSCRIPTION_URL_PARAM_KEYS.iter().find_map(|key| {
        let key = key.as_bytes();
        (bytes.len() >= index + key.len()
            && bytes[index..index + key.len()].eq_ignore_ascii_case(key))
        .then_some(key.len())
    })
}

fn is_subscription_url_param_boundary(bytes: &[u8], index: usize) -> bool {
    index == 0
        || matches!(
            bytes[index - 1],
            b'?' | b'&' | b';' | b'"' | b'\'' | b'(' | b' ' | b'\n' | b'\r' | b'\t'
        )
}

fn find_subscription_url_param_end(text: &str, start: usize) -> usize {
    text[start..]
        .char_indices()
        .find_map(|(offset, c)| {
            (c.is_whitespace()
                || matches!(c, '"' | '\'' | '<' | '>' | ')' | ']' | '}' | '`')
                || (c == '&' && should_end_subscription_url_param_at_amp(text, start + offset)))
            .then_some(start + offset)
        })
        .unwrap_or(text.len())
}

fn should_end_subscription_url_param_at_amp(text: &str, amp_index: usize) -> bool {
    let mut key_start = amp_index + 1;
    if text
        .get(key_start..)
        .is_some_and(|value| starts_with_ascii_case_insensitive(value, "amp;"))
    {
        key_start += "amp;".len();
    }
    let Some(rest) = text.get(key_start..) else {
        return true;
    };
    let Some(eq_offset) = rest.find('=') else {
        return true;
    };
    let key_end = key_start + eq_offset;
    let key = &text[key_start..key_end];
    if key.is_empty()
        || key
            .as_bytes()
            .iter()
            .any(|byte| !matches!(byte, b'a'..=b'z' | b'A'..=b'Z' | b'0'..=b'9' | b'_' | b'-'))
    {
        return true;
    }
    !SUBSCRIPTION_VALUE_QUERY_KEYS
        .iter()
        .any(|value| key.eq_ignore_ascii_case(value))
}

fn discover_github_api_urls(text: &str, base_url: &str) -> Option<Vec<String>> {
    let Ok(value) = serde_json::from_str::<Value>(text) else {
        return None;
    };
    if let Some(urls) = discover_github_repo_metadata_urls(&value, base_url) {
        return Some(urls);
    }
    let base = github_api_base(base_url)?;
    let mut urls = Vec::with_capacity(github_api_url_capacity_hint(&value));
    collect_github_api_urls(&value, &base, &mut urls);
    Some(urls)
}

fn discover_github_repo_metadata_urls(value: &Value, base_url: &str) -> Option<Vec<String>> {
    let parsed = Url::parse(base_url).ok()?;
    if !parsed.host_str()?.eq_ignore_ascii_case("api.github.com") {
        return None;
    }
    let mut segments = parsed.path_segments()?;
    if segments.next()? != "repos" {
        return None;
    }
    let owner = segments.next()?;
    let repo = segments.next()?;
    if segments.next().is_some() {
        return None;
    }
    let default_branch = value
        .as_object()?
        .get("default_branch")
        .and_then(string_value)?;
    let branch = default_branch.trim();
    if branch.is_empty() {
        return Some(Vec::new());
    }
    let mut urls = Vec::with_capacity(2 + GITHUB_RAW_SEED_PATHS.len());
    urls.push(format!(
        "https://api.github.com/repos/{owner}/{repo}/contents?ref={branch}"
    ));
    urls.push(format!(
        "https://api.github.com/repos/{owner}/{repo}/git/trees/{branch}?recursive=1"
    ));
    for path in GITHUB_RAW_SEED_PATHS {
        urls.push(raw_github_url(owner, repo, branch, path));
    }
    Some(urls)
}

fn github_api_url_capacity_hint(value: &Value) -> usize {
    match value {
        Value::Array(items) => items.len(),
        Value::Object(object) => object.get("tree").and_then(Value::as_array).map_or_else(
            || {
                ["download_url", "html_url", "raw_url"]
                    .iter()
                    .filter(|key| object.get(**key).is_some())
                    .count()
            },
            Vec::len,
        ),
        _ => 0,
    }
}

struct GithubApiBase {
    owner: String,
    repo: String,
    reference: String,
}

fn github_api_base(url: &str) -> Option<GithubApiBase> {
    let parsed = Url::parse(url).ok()?;
    if !parsed.host_str()?.eq_ignore_ascii_case("api.github.com") {
        return None;
    }
    let mut segments = parsed.path_segments()?;
    if segments.next()? != "repos" {
        return None;
    }
    let owner = segments.next()?.to_string();
    let repo = segments.next()?.to_string();
    let segment = segments.next()?;
    let reference = if segment == "contents" {
        parsed
            .query_pairs()
            .find(|(key, _)| key == "ref")
            .map(|(_, value)| value.to_string())
            .filter(|value| !value.is_empty())
            .unwrap_or_else(|| "main".to_string())
    } else if segment == "git" && segments.next()? == "trees" {
        segments.next()?.to_string()
    } else {
        return None;
    };
    Some(GithubApiBase {
        owner,
        repo,
        reference,
    })
}

fn collect_github_api_urls(value: &Value, base: &GithubApiBase, urls: &mut Vec<String>) {
    match value {
        Value::Array(items) => {
            for item in items {
                collect_github_api_urls(item, base, urls);
            }
        }
        Value::Object(object) => {
            for key in ["download_url", "html_url", "raw_url"] {
                if let Some(url) = object.get(key).and_then(string_value) {
                    if !url.is_empty() {
                        urls.push(url);
                    }
                }
            }
            let entry_type = object.get("type").and_then(string_value);
            if entry_type
                .as_deref()
                .is_some_and(|value| matches!(value, "dir" | "tree"))
            {
                if let Some(url) = object.get("url").and_then(string_value) {
                    if !url.is_empty() {
                        urls.push(url);
                    }
                }
            }
            let is_file = entry_type
                .as_deref()
                .is_none_or(|value| matches!(value, "blob" | "file"));
            if is_file {
                if let Some(path) = object.get("path").and_then(string_value) {
                    if is_github_api_config_path(&path) {
                        urls.push(raw_github_url_from_path(base, &path));
                    }
                }
            }
            for value in object.values() {
                if matches!(value, Value::Array(_) | Value::Object(_)) {
                    collect_github_api_urls(value, base, urls);
                }
            }
        }
        _ => {}
    }
}

fn raw_github_url_from_path(base: &GithubApiBase, path: &str) -> String {
    raw_github_url(
        &base.owner,
        &base.repo,
        &base.reference,
        path.trim_start_matches('/'),
    )
}

fn raw_github_url(owner: &str, repo: &str, reference: &str, path: &str) -> String {
    format!("https://raw.githubusercontent.com/{owner}/{repo}/{reference}/{path}")
}

fn is_github_api_config_path(path: &str) -> bool {
    let path = path
        .split_once(['?', '#'])
        .map(|(path, _)| path)
        .unwrap_or(path)
        .trim_matches('/');
    if is_unsupported_github_proxy_data_path(path) {
        return false;
    }
    if is_github_readme_markdown_path(path) {
        return true;
    }
    if is_known_github_json_config_path(path) {
        return true;
    }
    if has_config_extension_in_path(path) && !ends_with_ascii_case_insensitive(path, ".json") {
        return true;
    }
    let file_name = path.rsplit('/').next().unwrap_or(path);
    if file_name.contains('.') {
        return false;
    }
    GITHUB_RAW_SEED_PATHS.contains(&file_name)
}

fn is_github_readme_markdown_path(path: &str) -> bool {
    let file_name = path.rsplit('/').next().unwrap_or(path);
    starts_with_ascii_case_insensitive(file_name, "readme")
        && ends_with_ascii_case_insensitive(file_name, ".md")
}

fn is_known_github_json_config_path(path: &str) -> bool {
    if is_known_github_proxy_data_path(path) {
        return true;
    }
    if is_provider_directory_json_config_path(path) {
        return true;
    }
    let file_name = path.rsplit('/').next().unwrap_or(path);
    matches!(
        file_name,
        "sing-box.json"
            | "singbox.json"
            | "outbounds.json"
            | "provider.json"
            | "providers.json"
            | "proxy-providers.json"
            | "proxy_providers.json"
    )
}

fn is_provider_directory_json_config_path(path: &str) -> bool {
    let mut segments = path.split('/');
    matches!(
        segments.next(),
        Some("provider" | "providers" | "proxy-providers" | "proxy_providers")
    ) && segments
        .next()
        .is_some_and(|file_name| ends_with_ascii_case_insensitive(file_name, ".json"))
        && segments.next().is_none()
}

fn is_known_github_proxy_data_path(path: &str) -> bool {
    is_protocol_split_json_proxy_list_path(path)
        || is_all_proxy_data_path(path)
        || is_root_proxy_data_path(path)
        || is_protocol_root_proxy_data_path(path)
        || is_online_proxy_data_path(path)
}

fn is_unsupported_github_proxy_data_path(path: &str) -> bool {
    let mut segments = path.split('/');
    match segments.next() {
        Some("proxies") => {
            matches!(segments.next(), Some("protocols"))
                && matches!(segments.next(), Some("socks4"))
                && matches!(segments.next(), Some("data.json" | "data.txt" | "data.csv"))
                && segments.next().is_none()
        }
        Some("protocols") => {
            matches!(segments.next(), Some("socks4.txt")) && segments.next().is_none()
        }
        Some("online-proxies") => {
            matches!(segments.next(), Some("txt"))
                && matches!(segments.next(), Some("proxies-socks4.txt"))
                && segments.next().is_none()
        }
        Some("socks4.txt") => segments.next().is_none(),
        _ => false,
    }
}

fn is_protocol_split_json_proxy_list_path(path: &str) -> bool {
    let mut segments = path.split('/');
    matches!(segments.next(), Some("proxies"))
        && matches!(segments.next(), Some("protocols"))
        && matches!(segments.next(), Some("http" | "https" | "socks5"))
        && matches!(segments.next(), Some("data.json" | "data.txt" | "data.csv"))
        && segments.next().is_none()
}

fn is_all_proxy_data_path(path: &str) -> bool {
    let mut segments = path.split('/');
    matches!(segments.next(), Some("proxies"))
        && matches!(segments.next(), Some("all"))
        && matches!(segments.next(), Some("data.json" | "data.txt" | "data.csv"))
        && segments.next().is_none()
}

fn is_root_proxy_data_path(path: &str) -> bool {
    matches!(
        path,
        "all-proxies.txt"
            | "all.csv"
            | "all.json"
            | "free.csv"
            | "free.json"
            | "http.csv"
            | "https.csv"
            | "node.csv"
            | "node.json"
            | "nodes.csv"
            | "nodes.json"
            | "proxies.csv"
            | "proxy.json"
            | "proxy.csv"
            | "proxies.json"
            | "proxylist.txt"
            | "proxylist.csv"
            | "proxylist.json"
            | "proxylist.yaml"
            | "proxylist.yml"
            | "proxylist.xml"
            | "proxylist.phps"
            | "proxy-list.csv"
            | "proxy-list.json"
            | "proxy-list.yaml"
            | "proxy-list.yml"
            | "socks5.csv"
    )
}

fn is_protocol_root_proxy_data_path(path: &str) -> bool {
    let mut segments = path.split('/');
    matches!(segments.next(), Some("protocols"))
        && matches!(
            segments.next(),
            Some("http.txt" | "https.txt" | "socks5.txt" | "http.csv" | "https.csv" | "socks5.csv")
        )
        && segments.next().is_none()
}

fn is_online_proxy_data_path(path: &str) -> bool {
    let mut segments = path.split('/');
    matches!(segments.next(), Some("online-proxies"))
        && match segments.next() {
            Some("txt") => matches!(
                segments.next(),
                Some(
                    "proxies.txt" | "proxies-http.txt" | "proxies-https.txt" | "proxies-socks5.txt"
                )
            ),
            Some("csv") => matches!(segments.next(), Some("proxies.csv")),
            Some("json") => matches!(segments.next(), Some("proxies.json" | "proxies-basic.json")),
            Some("yaml") => {
                matches!(segments.next(), Some("proxies.yaml" | "proxies-basic.yaml"))
            }
            Some("xml") => matches!(segments.next(), Some("proxies.xml" | "proxies-basic.xml")),
            _ => false,
        }
        && segments.next().is_none()
}

fn for_each_absolute_url(text: &str, mut on_url: impl FnMut(String)) {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        if !absolute_url_prefix_at(bytes, cursor) {
            cursor += 1;
            continue;
        }
        let start = cursor;
        let end = text[start..]
            .find(|c: char| {
                c.is_whitespace() || matches!(c, '"' | '\'' | '<' | '>' | ')' | ']' | '}')
            })
            .map(|value| start + value)
            .unwrap_or(text.len());
        let url_end = chained_absolute_url_start_after_config(text, start, end).unwrap_or(end);
        on_url(normalize_url(&text[start..url_end]));
        cursor = if url_end < end {
            url_end
        } else {
            end.saturating_add(1)
        };
    }
}

fn chained_absolute_url_start_after_config(text: &str, start: usize, end: usize) -> Option<usize> {
    let bytes = text.as_bytes();
    let mut cursor = start + 1;
    while cursor < end {
        if absolute_url_prefix_at(bytes, cursor) && is_strong_config_candidate(&text[start..cursor])
        {
            return Some(cursor);
        }
        cursor += 1;
    }
    None
}

fn absolute_url_prefix_at(bytes: &[u8], index: usize) -> bool {
    let rest = &bytes[index..];
    starts_with_ascii_bytes(rest, b"https://")
        || starts_with_ascii_bytes(rest, b"http://")
        || protocol_relative_url_prefix_at(bytes, index)
}

fn protocol_relative_url_prefix_at(bytes: &[u8], index: usize) -> bool {
    if index > 0 && bytes[index - 1] == b':' {
        return false;
    }
    bytes.get(index) == Some(&b'/')
        && bytes.get(index + 1) == Some(&b'/')
        && bytes
            .get(index + 2)
            .is_some_and(|byte| byte.is_ascii_alphanumeric())
}

fn add_escaped_absolute_urls(text: &str, result: &mut Vec<String>, index: &mut DiscoveredUrlIndex) {
    let mut cursor = 0;
    while cursor < text.len() {
        let rest = &text[cursor..];
        let Some(offset) = escaped_absolute_url_offset(rest) else {
            break;
        };
        let start = cursor + offset;
        let end = text[start..]
            .find(|c: char| {
                c.is_whitespace() || matches!(c, '"' | '\'' | '<' | '>' | ')' | ']' | '}')
            })
            .map(|value| start + value)
            .unwrap_or(text.len());
        let unescaped = text[start..end].replace("\\/", "/");
        insert_ordered_discovered_url(result, index, normalize_url(&unescaped), None);
        cursor = end.saturating_add(1);
    }
}

fn escaped_absolute_url_offset(value: &str) -> Option<usize> {
    [r"https:\/\/", r"http:\/\/"]
        .into_iter()
        .filter_map(|needle| value.find(needle))
        .chain(protocol_relative_escaped_url_offsets(value))
        .min()
}

fn protocol_relative_escaped_url_offsets(value: &str) -> impl Iterator<Item = usize> + '_ {
    let bytes = value.as_bytes();
    value.match_indices(r"\/\/").filter_map(move |(index, _)| {
        if index > 0 && bytes[index - 1] == b':' {
            return None;
        }
        bytes
            .get(index + r"\/\/".len())
            .is_some_and(|byte| byte.is_ascii_alphanumeric())
            .then_some(index)
    })
}

fn add_attribute_discovered_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    for key in [
        "href=\"",
        "href='",
        "data-url=\"",
        "data-url='",
        "data-sub=\"",
        "data-sub='",
        "data-subscribe-url=\"",
        "data-subscribe-url='",
        "data-subscription-url=\"",
        "data-subscription-url='",
        "data-href=\"",
        "data-href='",
        "data-clipboard-text=\"",
        "data-clipboard-text='",
        "download_url\":\"",
        "html_url\":\"",
    ] {
        let mut cursor = 0;
        while let Some(offset) = text[cursor..].find(key) {
            let start = cursor + offset + key.len();
            let quote = if key.ends_with('\'') { '\'' } else { '"' };
            let end = text[start..]
                .find(quote)
                .map(|value| start + value)
                .unwrap_or(text.len());
            insert_ordered_discovered_url(
                result,
                index,
                unescape_discovery_url_value(&text[start..end]).into_owned(),
                base,
            );
            cursor = end.saturating_add(1);
        }
    }
    add_flexible_attribute_discovered_urls(text, result, index, base);
}

fn add_meta_refresh_url_values(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    let mut cursor = 0;
    while let Some(offset) = text[cursor..].find('<') {
        let tag_start = cursor + offset;
        let Some(tag_end_offset) = text[tag_start..].find('>') else {
            break;
        };
        let tag_end = tag_start + tag_end_offset;
        let tag = &text[tag_start..tag_end];
        cursor = tag_end.saturating_add(1);
        if !starts_with_ascii_case_insensitive(tag.trim_start_matches('<').trim_start(), "meta")
            || !contains_ascii_case_insensitive(tag, "refresh")
        {
            continue;
        }
        let Some(content) = html_attribute_value(tag, "content") else {
            continue;
        };
        let Some(url) = meta_refresh_content_url(content) else {
            continue;
        };
        let url = trim_meta_refresh_url_value(url);
        let url = unescape_discovery_url_value(url);
        if should_keep_yaml_config_url_value(&url) {
            insert_ordered_discovered_url(result, index, url.into_owned(), base);
        }
    }
}

fn trim_meta_refresh_url_value(value: &str) -> &str {
    value
        .trim()
        .trim_matches(|ch| matches!(ch, '\'' | '"'))
        .trim()
}

fn html_attribute_value<'a>(tag: &'a str, attribute_name: &str) -> Option<&'a str> {
    let bytes = tag.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        while cursor < bytes.len() && !is_attribute_name_byte(bytes[cursor]) {
            cursor += 1;
        }
        let name_start = cursor;
        while cursor < bytes.len() && is_attribute_name_byte(bytes[cursor]) {
            cursor += 1;
        }
        let name = &tag[name_start..cursor];
        let mut value_start = cursor;
        while value_start < bytes.len() && bytes[value_start].is_ascii_whitespace() {
            value_start += 1;
        }
        if value_start >= bytes.len() || bytes[value_start] != b'=' {
            cursor = value_start.saturating_add(1);
            continue;
        }
        value_start += 1;
        while value_start < bytes.len() && bytes[value_start].is_ascii_whitespace() {
            value_start += 1;
        }
        if value_start >= bytes.len() {
            return None;
        }
        let (raw_start, raw_end) = match bytes[value_start] {
            b'\'' | b'"' => {
                let quote = bytes[value_start];
                let start = value_start + 1;
                (start, find_quoted_value_end(tag, start, quote))
            }
            _ => {
                let end = tag[value_start..]
                    .char_indices()
                    .find_map(|(offset, c)| {
                        (c.is_whitespace() || matches!(c, '<' | '>'))
                            .then_some(value_start + offset)
                    })
                    .unwrap_or(tag.len());
                (value_start, end)
            }
        };
        if name.eq_ignore_ascii_case(attribute_name) {
            return tag.get(raw_start..raw_end);
        }
        cursor = raw_end.saturating_add(1);
    }
    None
}

fn meta_refresh_content_url(content: &str) -> Option<&str> {
    let bytes = content.as_bytes();
    let mut cursor = 0;
    while cursor + 3 <= bytes.len() {
        if bytes[cursor..].len() >= 3 && bytes[cursor..cursor + 3].eq_ignore_ascii_case(b"url") {
            let mut value_start = cursor + 3;
            while value_start < bytes.len() && bytes[value_start].is_ascii_whitespace() {
                value_start += 1;
            }
            if value_start < bytes.len() && bytes[value_start] == b'=' {
                value_start += 1;
                while value_start < bytes.len() && bytes[value_start].is_ascii_whitespace() {
                    value_start += 1;
                }
                let value_end = content[value_start..]
                    .char_indices()
                    .find_map(|(offset, c)| (c == ';').then_some(value_start + offset))
                    .unwrap_or(content.len());
                let url = content[value_start..value_end].trim();
                if !url.is_empty() {
                    return Some(url);
                }
            }
        }
        cursor += 1;
    }
    None
}

fn add_flexible_attribute_discovered_urls(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        if !is_attribute_name_byte(bytes[cursor]) {
            cursor += 1;
            continue;
        }
        let name_start = cursor;
        while cursor < bytes.len() && is_attribute_name_byte(bytes[cursor]) {
            cursor += 1;
        }
        let name = &text[name_start..cursor];
        if !is_discovery_attribute_name(name) {
            continue;
        }
        let mut value_start = cursor;
        while value_start < bytes.len() && bytes[value_start].is_ascii_whitespace() {
            value_start += 1;
        }
        if value_start >= bytes.len() || bytes[value_start] != b'=' {
            cursor = value_start;
            continue;
        }
        value_start += 1;
        while value_start < bytes.len() && bytes[value_start].is_ascii_whitespace() {
            value_start += 1;
        }
        if value_start >= bytes.len() {
            break;
        }
        let (raw_start, raw_end) = match bytes[value_start] {
            b'\'' | b'"' => {
                let quote = bytes[value_start];
                let start = value_start + 1;
                (start, find_quoted_value_end(text, start, quote))
            }
            _ => {
                let end = text[value_start..]
                    .char_indices()
                    .find_map(|(offset, c)| {
                        (c.is_whitespace() || matches!(c, '<' | '>'))
                            .then_some(value_start + offset)
                    })
                    .unwrap_or(text.len());
                (value_start, end)
            }
        };
        if raw_start < raw_end {
            let value = unescape_discovery_url_value(&text[raw_start..raw_end]);
            insert_attribute_discovered_urls(name, &value, result, index, base);
        }
        cursor = raw_end.saturating_add(1);
    }
}

fn insert_attribute_discovered_urls(
    name: &str,
    value: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    if should_keep_attribute_url(name, value) {
        insert_ordered_discovered_url(result, index, value.to_string(), base);
        return;
    }
    if is_value_attribute_name(name) {
        let Some(decoded) = decode_base64_text(value.trim()) else {
            return;
        };
        let normalized = normalize_url(&decoded);
        if should_keep_value_attribute_url(&normalized) {
            insert_ordered_discovered_url(result, index, normalized, base);
        }
        return;
    }
    if !is_subscription_attribute_name(name) {
        return;
    }
    let Some(decoded) = decode_base64_text(value.trim()) else {
        return;
    };
    let normalized = normalize_url(&decoded);
    if should_keep_attribute_url(name, &normalized) {
        insert_ordered_discovered_url(result, index, normalized, base);
    }
}

fn unescape_discovery_url_value(value: &str) -> Cow<'_, str> {
    let has_slash_escape = value.contains("\\/");
    let has_html_entity = has_proxy_uri_html_entity_hint(value);
    if !has_slash_escape && !has_html_entity {
        return Cow::Borrowed(value);
    }
    let mut decoded = if has_slash_escape {
        value.replace("\\/", "/")
    } else {
        value.to_string()
    };
    if let Some(entity_decoded) = decode_proxy_uri_html_entities(&decoded) {
        decoded = entity_decoded;
    }
    Cow::Owned(decoded)
}

fn is_attribute_name_byte(byte: u8) -> bool {
    byte.is_ascii_alphanumeric() || matches!(byte, b'-' | b'_' | b':')
}

fn is_discovery_attribute_name(name: &str) -> bool {
    [
        "href",
        "data-url",
        "data-sub",
        "data-sub-url",
        "data-subscribe",
        "data-subscribe-link",
        "data-subscription",
        "data-subscription-link",
        "data-subscribe-url",
        "data-subscription-url",
        "data-profile",
        "data-profile-url",
        "data-profile-link",
        "data-config",
        "data-clash",
        "data-clash-url",
        "data-v2ray-url",
        "data-node-url",
        "data-source-url",
        "data-copy",
        "data-copy-url",
        "data-copy-link",
        "data-link",
        "data-link-url",
        "data-link-href",
        "data-download",
        "data-download-url",
        "data-download-link",
        "data-href",
        "data-clipboard-text",
        "value",
    ]
    .iter()
    .any(|candidate| name.eq_ignore_ascii_case(candidate))
}

fn is_subscription_attribute_name(name: &str) -> bool {
    [
        "data-sub",
        "data-sub-url",
        "data-subscribe",
        "data-subscribe-link",
        "data-subscription",
        "data-subscription-link",
        "data-subscribe-url",
        "data-subscription-url",
        "data-profile",
        "data-profile-url",
        "data-profile-link",
        "data-config",
        "data-clash",
        "data-clash-url",
        "data-v2ray-url",
        "data-node-url",
        "data-source-url",
        "data-copy",
        "data-copy-url",
        "data-copy-link",
        "data-link",
        "data-link-url",
        "data-link-href",
        "data-download",
        "data-download-url",
        "data-download-link",
        "data-clipboard-text",
    ]
    .iter()
    .any(|candidate| name.eq_ignore_ascii_case(candidate))
}

fn should_keep_attribute_url(name: &str, value: &str) -> bool {
    let value = value.trim();
    if value.is_empty() {
        return false;
    }
    if is_static_asset_path(value) {
        return false;
    }
    if is_value_attribute_name(name) {
        return should_keep_value_attribute_url(value);
    }
    if is_subscription_attribute_name(name) {
        starts_with_ascii_case_insensitive(value, "http://")
            || starts_with_ascii_case_insensitive(value, "https://")
            || value.starts_with("//")
            || is_relative_config_candidate(value)
            || is_contextual_relative_config_candidate(value)
    } else {
        true
    }
}

fn is_value_attribute_name(name: &str) -> bool {
    name.eq_ignore_ascii_case("value")
}

fn should_keep_value_attribute_url(value: &str) -> bool {
    if starts_with_ascii_case_insensitive(value, "http://")
        || starts_with_ascii_case_insensitive(value, "https://")
    {
        return is_strong_config_candidate(value);
    }
    value.starts_with("//")
        || is_relative_config_candidate(value)
        || is_contextual_relative_config_candidate(value)
}

fn add_relative_config_string_values(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor < bytes.len() {
        let quote = bytes[cursor];
        if !is_discovery_string_literal_quote(quote) {
            cursor += 1;
            continue;
        }
        let start = cursor + 1;
        let end = find_quoted_value_end(text, start, quote);
        if start < end {
            let raw = &text[start..end];
            if quote == b'`' && contains_template_interpolation(raw) {
                cursor = end.saturating_add(1);
                continue;
            }
            if is_concatenated_string_literal_piece(text, cursor, end) {
                if is_first_concatenated_string_literal(text, cursor)
                    && has_script_navigation_context(text, cursor)
                {
                    if let Some((value, chain_end)) =
                        read_concatenated_string_literal_value(text, cursor)
                    {
                        if is_contextual_relative_config_candidate(&value) {
                            insert_ordered_discovered_url(result, index, value, base);
                        }
                        cursor = chain_end.saturating_add(1);
                        continue;
                    }
                }
                cursor = end.saturating_add(1);
                continue;
            }
            if looks_like_relative_url_literal(raw) {
                let value = unescape_discovery_url_value(raw);
                if is_relative_config_candidate(&value)
                    || (has_subscription_field_context(text, cursor)
                        && is_contextual_relative_config_candidate(&value))
                    || (has_script_navigation_context(text, cursor)
                        && is_contextual_relative_config_candidate(&value))
                {
                    insert_ordered_discovered_url(result, index, value.into_owned(), base);
                }
            }
        }
        cursor = end.saturating_add(1);
    }
}

fn add_html_entity_quoted_relative_config_string_values(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    let mut cursor = 0;
    while cursor < text.len() {
        let Some((quote_start, quote_len)) = find_next_html_entity_quote(text, cursor) else {
            break;
        };
        let value_start = quote_start + quote_len;
        let Some((quote_end, end_quote_len)) = find_next_html_entity_quote(text, value_start)
        else {
            break;
        };
        if value_start < quote_end {
            let raw = &text[value_start..quote_end];
            if !contains_template_interpolation(raw) && looks_like_relative_url_literal(raw) {
                let value = unescape_discovery_url_value(raw);
                if (has_subscription_field_context(text, quote_start)
                    || has_script_navigation_context(text, quote_start))
                    && is_contextual_relative_config_candidate(&value)
                {
                    insert_ordered_discovered_url(result, index, value.into_owned(), base);
                }
            }
        }
        cursor = quote_end.saturating_add(end_quote_len);
    }
}

fn find_next_html_entity_quote(text: &str, from: usize) -> Option<(usize, usize)> {
    let bytes = text.as_bytes();
    let mut cursor = from;
    while cursor < bytes.len() {
        if let Some(len) = html_entity_quote_len_at(bytes, cursor) {
            return Some((cursor, len));
        }
        cursor += 1;
    }
    None
}

fn html_entity_quote_len_at(bytes: &[u8], index: usize) -> Option<usize> {
    for entity in [
        b"&quot;".as_slice(),
        b"&#39;".as_slice(),
        b"&#x27;".as_slice(),
    ] {
        let end = index.saturating_add(entity.len());
        if end <= bytes.len() && bytes[index..end].eq_ignore_ascii_case(entity) {
            return Some(entity.len());
        }
    }
    None
}

fn is_discovery_string_literal_quote(byte: u8) -> bool {
    matches!(byte, b'\'' | b'"' | b'`')
}

fn contains_template_interpolation(value: &str) -> bool {
    value.as_bytes().windows(2).any(|window| window == b"${")
}

fn is_concatenated_string_literal_piece(text: &str, quote_index: usize, value_end: usize) -> bool {
    previous_significant_byte(text, quote_index) == Some(b'+')
        || next_significant_byte(text, value_end + 1) == Some(b'+')
}

fn is_first_concatenated_string_literal(text: &str, quote_index: usize) -> bool {
    previous_significant_byte(text, quote_index) != Some(b'+')
}

fn read_concatenated_string_literal_value(
    text: &str,
    quote_index: usize,
) -> Option<(String, usize)> {
    let bytes = text.as_bytes();
    let quote = *bytes.get(quote_index)?;
    if !matches!(quote, b'\'' | b'"') {
        return None;
    }
    let mut cursor = quote_index;
    let mut combined = String::new();
    let mut pieces = 0;
    let mut chain_end: usize;
    loop {
        let current_quote = *bytes.get(cursor)?;
        if !matches!(current_quote, b'\'' | b'"') {
            return None;
        }
        let start = cursor + 1;
        let end = find_quoted_value_end(text, start, current_quote);
        if start >= end {
            return None;
        }
        combined.push_str(&unescape_discovery_url_value(&text[start..end]));
        pieces += 1;
        chain_end = end;
        let Some(plus_index) = next_significant_index(text, end + 1) else {
            break;
        };
        if bytes[plus_index] != b'+' {
            break;
        }
        let Some(next_quote_index) = next_significant_index(text, plus_index + 1) else {
            break;
        };
        if !matches!(bytes[next_quote_index], b'\'' | b'"') {
            break;
        }
        cursor = next_quote_index;
    }
    (pieces > 1).then_some((combined, chain_end))
}

fn previous_significant_byte(text: &str, before: usize) -> Option<u8> {
    text.as_bytes()
        .get(..before)?
        .iter()
        .rev()
        .find(|byte| !byte.is_ascii_whitespace())
        .copied()
}

fn next_significant_byte(text: &str, from: usize) -> Option<u8> {
    next_significant_index(text, from).map(|index| text.as_bytes()[index])
}

fn next_significant_index(text: &str, from: usize) -> Option<usize> {
    text.as_bytes()
        .get(from..)?
        .iter()
        .position(|byte| !byte.is_ascii_whitespace())
        .map(|offset| from + offset)
}

fn add_yaml_config_url_values(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    for line in text.lines() {
        let Some(raw) = yaml_config_url_field_value(line) else {
            continue;
        };
        let value = unescape_discovery_url_value(raw);
        let value = trim_yaml_config_url_value(&value);
        if should_keep_yaml_config_url_value(value) {
            insert_ordered_discovered_url(result, index, value.to_string(), base);
        }
    }
}

fn yaml_config_url_field_value(line: &str) -> Option<&str> {
    let mut value = line.trim_start();
    if value.starts_with('#') {
        return None;
    }
    if let Some(stripped) = value.strip_prefix('-') {
        value = stripped.trim_start();
    }
    let (key, raw_value) = value.split_once(':')?;
    let key = key.trim().trim_matches(['"', '\'']);
    key.eq_ignore_ascii_case("url").then_some(raw_value)
}

fn trim_yaml_config_url_value(value: &str) -> &str {
    let value = value.trim();
    let value = value
        .strip_prefix(['"', '\''])
        .unwrap_or(value)
        .trim_start();
    let comment_start = value
        .match_indices('#')
        .find_map(|(index, _)| {
            (index == 0
                || value
                    .as_bytes()
                    .get(..index)
                    .and_then(|bytes| bytes.last())
                    .is_some_and(u8::is_ascii_whitespace))
            .then_some(index)
        })
        .unwrap_or(value.len());
    value[..comment_start]
        .trim_end()
        .trim_end_matches(',')
        .trim_end_matches(['"', '\''])
        .trim()
}

fn should_keep_yaml_config_url_value(value: &str) -> bool {
    if value.is_empty() || is_static_asset_path(value) {
        return false;
    }
    starts_with_ascii_case_insensitive(value, "http://")
        || starts_with_ascii_case_insensitive(value, "https://")
        || value.starts_with("//")
        || is_relative_config_candidate(value)
        || is_contextual_relative_config_candidate(value)
}

fn add_markdown_config_links(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    add_markdown_reference_config_links(text, result, index, base);
    let bytes = text.as_bytes();
    let mut cursor = 0;
    while cursor + 1 < bytes.len() {
        if bytes[cursor] != b']' || bytes[cursor + 1] != b'(' {
            cursor += 1;
            continue;
        }
        let label = markdown_link_label_before(text, cursor);
        let mut start = cursor + 2;
        while start < bytes.len() && bytes[start].is_ascii_whitespace() {
            start += 1;
        }
        if start >= bytes.len() {
            break;
        }
        let angle_wrapped = bytes[start] == b'<';
        if angle_wrapped {
            start += 1;
        }
        let end = find_markdown_link_url_end(text, start, angle_wrapped);
        if start < end {
            let raw = &text[start..end];
            let value = unescape_discovery_url_value(raw);
            if should_keep_markdown_config_link(label, &value) {
                insert_ordered_discovered_url(result, index, value.into_owned(), base);
            }
        }
        cursor = end.saturating_add(1);
    }
}

fn add_markdown_reference_config_links(
    text: &str,
    result: &mut Vec<String>,
    index: &mut DiscoveredUrlIndex,
    base: Option<&Url>,
) {
    for line in text.lines() {
        let Some((label, raw)) = markdown_reference_config_link(line) else {
            continue;
        };
        let value = unescape_discovery_url_value(raw);
        if should_keep_markdown_config_link(label, &value) {
            insert_ordered_discovered_url(result, index, value.into_owned(), base);
        }
    }
}

fn markdown_reference_config_link(line: &str) -> Option<(&str, &str)> {
    let line = line.trim_start();
    if !line.starts_with('[') {
        return None;
    }
    let close = line.find("]:")?;
    let label = line[1..close].trim();
    if label.is_empty() {
        return None;
    }
    let mut value_start = close + "]:".len();
    while line
        .as_bytes()
        .get(value_start)
        .is_some_and(u8::is_ascii_whitespace)
    {
        value_start += 1;
    }
    if value_start >= line.len() {
        return None;
    }
    let angle_wrapped = line.as_bytes()[value_start] == b'<';
    if angle_wrapped {
        value_start += 1;
    }
    let value_end = find_markdown_link_url_end(line, value_start, angle_wrapped);
    (value_start < value_end).then_some((label, &line[value_start..value_end]))
}

fn markdown_link_label_before(text: &str, close_bracket: usize) -> &str {
    let bytes = text.as_bytes();
    let mut cursor = close_bracket;
    while cursor > 0 {
        cursor -= 1;
        if bytes[cursor] == b'[' && (cursor == 0 || bytes[cursor - 1] != b'!') {
            return &text[cursor + 1..close_bracket];
        }
        if matches!(bytes[cursor], b'\n' | b'\r') {
            break;
        }
    }
    ""
}

fn find_markdown_link_url_end(text: &str, start: usize, angle_wrapped: bool) -> usize {
    text[start..]
        .char_indices()
        .find_map(|(offset, c)| {
            let is_end = if angle_wrapped {
                c == '>'
            } else {
                c.is_whitespace() || c == ')'
            };
            is_end.then_some(start + offset)
        })
        .unwrap_or(text.len())
}

fn should_keep_markdown_config_link(label: &str, value: &str) -> bool {
    let value = value.trim();
    if value.is_empty() || is_static_asset_path(value) {
        return false;
    }
    starts_with_ascii_case_insensitive(value, "http://")
        || starts_with_ascii_case_insensitive(value, "https://")
        || is_relative_config_candidate(value)
        || (markdown_label_has_subscription_context(label)
            && is_contextual_relative_config_candidate(value))
}

const MARKDOWN_LABEL_SUBSCRIPTION_HINTS: [&str; 5] =
    ["sub", "subscribe", "subscription", "clash", "v2ray"];

fn markdown_label_has_subscription_context(label: &str) -> bool {
    contains_any_ascii_case_insensitive(label, &MARKDOWN_LABEL_SUBSCRIPTION_HINTS)
        || label.contains("订阅")
        || label.contains("节点")
        || label.contains("免费")
}

fn find_quoted_value_end(text: &str, start: usize, quote: u8) -> usize {
    let bytes = text.as_bytes();
    let mut escaped = false;
    let mut cursor = start;
    while cursor < bytes.len() {
        let byte = bytes[cursor];
        if escaped {
            escaped = false;
        } else if byte == b'\\' {
            escaped = true;
        } else if byte == quote {
            return cursor;
        }
        cursor += 1;
    }
    text.len()
}

fn looks_like_relative_url_literal(value: &str) -> bool {
    value.starts_with('/')
        || value.starts_with('.')
        || value.starts_with("\\/")
        || looks_like_bare_relative_url_literal(value)
}

const RELATIVE_CONFIG_HINTS: [&str; 8] = [
    "subscription",
    "subscribe",
    "/sub/",
    "/sub?",
    "suburl=",
    "target=clash",
    "format=clash",
    "clash",
];

fn is_relative_config_candidate(value: &str) -> bool {
    let value = value.trim();
    let prefixed_relative = value.starts_with('/')
        || value.starts_with("./")
        || value.starts_with("../")
        || value.starts_with("//");
    let bare_relative = looks_like_bare_relative_url_literal(value);
    if !(prefixed_relative || bare_relative) {
        return false;
    }
    let has_config_extension = has_config_extension(value) || has_proxy_data_extension(value);
    if bare_relative && !has_config_extension && !value.contains('/') && !value.contains('?') {
        return false;
    }
    has_config_extension || contains_any_ascii_case_insensitive(value, &RELATIVE_CONFIG_HINTS)
}

fn has_subscription_field_context(text: &str, value_quote_index: usize) -> bool {
    let bytes = text.as_bytes();
    let mut cursor = value_quote_index;
    while cursor > 0 && bytes[cursor - 1].is_ascii_whitespace() {
        cursor -= 1;
    }
    if cursor == 0 || bytes[cursor - 1] != b':' {
        return false;
    }
    cursor -= 1;
    while cursor > 0 && bytes[cursor - 1].is_ascii_whitespace() {
        cursor -= 1;
    }
    if cursor == 0 {
        return false;
    }
    let key_end = cursor;
    let key_start = if matches!(bytes[key_end - 1], b'"' | b'\'') {
        let quote = bytes[key_end - 1];
        let mut key_start = key_end - 1;
        while key_start > 0 {
            key_start -= 1;
            if bytes[key_start] == quote && (key_start == 0 || bytes[key_start - 1] != b'\\') {
                return is_subscription_field_key(&text[key_start + 1..key_end - 1]);
            }
        }
        return false;
    } else {
        let mut key_start = key_end;
        while key_start > 0 && is_field_key_byte(bytes[key_start - 1]) {
            key_start -= 1;
        }
        key_start
    };
    key_start < key_end && is_subscription_field_key(&text[key_start..key_end])
}

fn is_field_key_byte(byte: u8) -> bool {
    byte.is_ascii_alphanumeric() || matches!(byte, b'_' | b'$' | b'-')
}

const SUBSCRIPTION_FIELD_KEY_HINTS: [&str; 8] = [
    "suburl",
    "subscribe",
    "subscription",
    "sourceurl",
    "source_url",
    "downloadurl",
    "download_url",
    "download-url",
];

fn is_subscription_field_key(key: &str) -> bool {
    key.eq_ignore_ascii_case("sub")
        || contains_any_ascii_case_insensitive(key, &SUBSCRIPTION_FIELD_KEY_HINTS)
}

fn has_script_navigation_context(text: &str, value_quote_index: usize) -> bool {
    let Some(prefix) = text.get(..value_quote_index) else {
        return false;
    };
    let trimmed = prefix.trim_end();
    if let Some(call_prefix) = trimmed.strip_suffix('(') {
        return is_script_navigation_target(last_script_path_token(call_prefix));
    }
    if let Some(assign_prefix) = trimmed.strip_suffix('=') {
        return is_script_navigation_target(last_script_path_token(assign_prefix));
    }
    false
}

fn last_script_path_token(value: &str) -> &str {
    let value = value.trim_end();
    let start = value
        .char_indices()
        .rev()
        .find_map(|(index, c)| (!is_script_path_token_char(c)).then_some(index + c.len_utf8()))
        .unwrap_or(0);
    &value[start..]
}

fn is_script_path_token_char(c: char) -> bool {
    c.is_ascii_alphanumeric() || matches!(c, '_' | '$' | '.')
}

fn is_script_navigation_target(value: &str) -> bool {
    [
        "open",
        "window.open",
        "location.assign",
        "window.location.assign",
        "location.replace",
        "window.location.replace",
        "location",
        "window.location",
        "location.href",
        "window.location.href",
        "copy",
        "copyclash",
        "copyconfig",
        "copyprofile",
        "copysub",
        "copysubscribe",
        "copysubscription",
        "copytext",
        "copytoclipboard",
        "copyurl",
        "copylink",
        "clipboard.writeText",
        "navigator.clipboard.writeText",
        "setclipboard",
    ]
    .iter()
    .any(|candidate| value.eq_ignore_ascii_case(candidate))
}

const CONTEXTUAL_RELATIVE_CONFIG_HINTS: [&str; 6] =
    ["api", "free", "node", "sub", "clash", "v2ray"];

fn is_contextual_relative_config_candidate(value: &str) -> bool {
    let value = value.trim();
    if !(value.starts_with('/')
        || value.starts_with("./")
        || value.starts_with("../")
        || value.starts_with("//")
        || looks_like_bare_relative_url_literal(value))
    {
        return false;
    }
    if is_static_asset_path(value) {
        return false;
    }
    let has_config_extension = has_config_extension(value) || has_proxy_data_extension(value);
    if !has_config_extension && !value.contains('/') && !value.contains('?') {
        return false;
    }
    has_config_extension
        || contains_any_ascii_case_insensitive(value, &CONTEXTUAL_RELATIVE_CONFIG_HINTS)
}

fn is_static_asset_path(value: &str) -> bool {
    let path = value
        .split_once(['?', '#'])
        .map(|(path, _)| path)
        .unwrap_or(value);
    [
        ".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".css", ".js", ".ico", ".woff", ".woff2",
    ]
    .iter()
    .any(|suffix| ends_with_ascii_case_insensitive(path, suffix))
}

fn looks_like_bare_relative_url_literal(value: &str) -> bool {
    let value = value.trim();
    !value.is_empty()
        && !value.starts_with('#')
        && !value.starts_with('?')
        && !value.contains("://")
        && !value
            .chars()
            .any(|c| c.is_whitespace() || matches!(c, '"' | '\'' | '<' | '>' | '{' | '}'))
}

const GITHUB_API_TREE_HINTS: [&str; 2] = ["/contents", "/git/trees/"];

const STRONG_CONFIG_URL_HINTS: [&str; 11] = [
    "raw.githubusercontent.com",
    "clash.crossxx.com",
    "freeclash.top/ui/free_clash",
    "freeclash.top/v1/sub/",
    "/api/",
    "subscription",
    "subscribe",
    "/sub/",
    "/sub?",
    "suburl=",
    "clashnode.com/wp-content/uploads/",
];

const STATIC_PAGE_PATH_HINTS: [&str; 2] = ["/assets/", "/static/"];

fn is_strong_config_candidate(url: &str) -> bool {
    if !is_http_url(url) {
        return false;
    }
    if contains_ascii_case_insensitive(url, "api.github.com/repos/")
        && contains_any_ascii_case_insensitive(url, &GITHUB_API_TREE_HINTS)
    {
        return false;
    }
    has_config_extension(url)
        || has_proxy_data_extension(url)
        || contains_any_ascii_case_insensitive(url, &STRONG_CONFIG_URL_HINTS)
}

fn has_config_extension(value: &str) -> bool {
    if let Ok(url) = Url::parse(value) {
        return has_config_extension_in_path(url.path());
    }
    let path = value
        .split_once(['?', '#'])
        .map(|(path, _)| path)
        .unwrap_or(value);
    has_config_extension_in_path(path)
}

fn has_config_extension_in_path(path: &str) -> bool {
    [".yaml", ".yml", ".txt", ".json"]
        .iter()
        .any(|suffix| ends_with_ascii_case_insensitive(path, suffix))
}

fn has_proxy_data_extension(value: &str) -> bool {
    if let Ok(url) = Url::parse(value) {
        return has_proxy_data_extension_in_path(url.path());
    }
    let path = value
        .split_once(['?', '#'])
        .map(|(path, _)| path)
        .unwrap_or(value);
    has_proxy_data_extension_in_path(path)
}

fn has_proxy_data_extension_in_path(path: &str) -> bool {
    if is_static_asset_path(path) {
        return false;
    }
    let file_name = path.rsplit('/').next().unwrap_or(path);
    let has_data_extension = [".csv", ".xml", ".phps"]
        .iter()
        .any(|suffix| ends_with_ascii_case_insensitive(file_name, suffix));
    if has_data_extension
        && ["http.csv", "https.csv", "socks5.csv"]
            .iter()
            .any(|candidate| file_name.eq_ignore_ascii_case(candidate))
    {
        return true;
    }
    has_data_extension
        && contains_any_ascii_case_insensitive(
            file_name,
            &["proxy", "proxies", "node", "nodes", "free", "all"],
        )
}

fn is_page_candidate(url: &str) -> bool {
    if !is_http_url(url) {
        return false;
    }
    if is_strong_config_candidate(url)
        || contains_ascii_case_insensitive(url, "raw.githubusercontent.com")
    {
        return false;
    }
    if contains_any_ascii_case_insensitive(url, &STATIC_PAGE_PATH_HINTS) {
        return false;
    }
    !is_static_asset_path(url)
}

fn is_discovery_page_candidate(url: &str, source: &CandidateSource) -> bool {
    is_page_candidate(url) || is_relevant_same_host_script_candidate(url, &source.seed)
}

fn is_relevant_same_host_script_candidate(url: &str, source_seed: &str) -> bool {
    let Ok(parsed) = Url::parse(url) else {
        return false;
    };
    let Ok(seed) = Url::parse(source_seed) else {
        return false;
    };
    if parsed.host_str() != seed.host_str() {
        return false;
    }
    let path = parsed.path();
    if !ends_with_ascii_case_insensitive(path, ".js") {
        return false;
    }
    [
        "api",
        "clash",
        "config",
        "free",
        "node",
        "sub",
        "subscribe",
        "subscription",
        "v2ray",
    ]
    .iter()
    .any(|needle| contains_ascii_case_insensitive(path, needle))
}

fn normalize_url(url: &str) -> String {
    let trimmed = url.trim();
    let mut value = if trimmed.contains("&amp;") {
        trimmed.replace("&amp;", "&")
    } else {
        trimmed.to_string()
    };
    while value.as_bytes().last().is_some_and(|byte| {
        byte.is_ascii_whitespace()
            || matches!(byte, b'"' | b'\'' | b'<' | b'>' | b')' | b';' | b'\\')
    }) {
        value.pop();
    }
    if value.starts_with("//") {
        value.insert_str(0, "https:");
    }
    if contains_ascii_case_insensitive(&value, "github.com") {
        if let Some(raw) = github_file_page_to_raw(&value) {
            return raw;
        }
    }
    value
}

fn canonical_fetch_key(url: &str) -> String {
    let mut value = normalize_url(url);
    if !has_github_fetch_key_canonical_hint(&value) {
        return value;
    }
    while let Some(stripped) = strip_known_github_mirror_prefix(&value) {
        value = normalize_url(stripped);
    }
    if let Some(raw) = github_path_mirror_to_raw(&value) {
        value = raw;
    }
    if let Some(raw) = github_raw_refs_heads_to_branch(&value) {
        value = raw;
    }
    if let Some(api) = github_contents_default_ref_to_base(&value) {
        value = api;
    }
    value
}

fn has_github_fetch_key_canonical_hint(value: &str) -> bool {
    contains_ascii_case_insensitive(value, "github")
        || contains_ascii_case_insensitive(value, "jsdelivr.net/gh")
        || contains_ascii_case_insensitive(value, "rawgithubusercontent.deno.dev")
}

fn strip_known_github_mirror_prefix(url: &str) -> Option<&str> {
    let bytes = url.as_bytes();
    GITHUB_RAW_MIRROR_PREFIXES.iter().find_map(|prefix| {
        let prefix_bytes = prefix.as_bytes();
        if bytes.len() < prefix_bytes.len()
            || !bytes[..prefix_bytes.len()].eq_ignore_ascii_case(prefix_bytes)
        {
            return None;
        }
        let rest = &url[prefix.len()..];
        (starts_with_ascii_case_insensitive(rest, "http://")
            || starts_with_ascii_case_insensitive(rest, "https://"))
        .then_some(rest)
    })
}

fn github_file_page_to_raw(url: &str) -> Option<String> {
    let parsed = Url::parse(url).ok()?;
    if !parsed.host_str()?.eq_ignore_ascii_case("github.com") {
        return None;
    }
    let mut segments = parsed.path_segments()?;
    let owner = segments.next()?;
    let repo = segments.next()?;
    let action = segments.next()?;
    if action != "blob" && action != "raw" {
        return None;
    }
    let mut branch = segments.next()?;
    if branch == "refs" {
        if segments.next()? != "heads" {
            return None;
        }
        branch = segments.next()?;
    }
    let first_path = segments.next()?;
    let mut raw = String::with_capacity(url.len() + 16);
    raw.push_str("https://raw.githubusercontent.com/");
    raw.push_str(owner);
    raw.push('/');
    raw.push_str(repo);
    raw.push('/');
    raw.push_str(branch);
    raw.push('/');
    raw.push_str(first_path);
    for segment in segments {
        raw.push('/');
        raw.push_str(segment);
    }
    Some(raw)
}

fn github_raw_refs_heads_to_branch(url: &str) -> Option<String> {
    let parsed = Url::parse(url).ok()?;
    if !parsed
        .host_str()?
        .eq_ignore_ascii_case("raw.githubusercontent.com")
    {
        return None;
    }
    let mut segments = parsed.path_segments()?;
    let owner = segments.next()?;
    let repo = segments.next()?;
    if segments.next()? != "refs" || segments.next()? != "heads" {
        return None;
    }
    let branch = segments.next()?;
    let first_path = segments.next()?;
    let mut raw = String::with_capacity(url.len().saturating_sub("refs/heads/".len()));
    raw.push_str("https://raw.githubusercontent.com/");
    raw.push_str(owner);
    raw.push('/');
    raw.push_str(repo);
    raw.push('/');
    raw.push_str(branch);
    raw.push('/');
    raw.push_str(first_path);
    for segment in segments {
        raw.push('/');
        raw.push_str(segment);
    }
    Some(raw)
}

fn github_path_mirror_to_raw(url: &str) -> Option<String> {
    let parsed = Url::parse(url).ok()?;
    let host = parsed.host_str()?;
    if host.eq_ignore_ascii_case("rawgithubusercontent.deno.dev") {
        return github_raw_path_mirror_to_raw(parsed);
    }
    if !host.eq_ignore_ascii_case("cdn.jsdelivr.net")
        && !host.eq_ignore_ascii_case("fastly.jsdelivr.net")
        && !host.eq_ignore_ascii_case("gcore.jsdelivr.net")
    {
        return None;
    }
    let mut segments = parsed.path_segments()?;
    if segments.next()? != "gh" {
        return None;
    }
    let owner = segments.next()?;
    let repo_branch = segments.next()?;
    let (repo, branch) = repo_branch.split_once('@')?;
    let first_path = segments.next()?;
    let mut raw = String::with_capacity(url.len() + 16);
    raw.push_str("https://raw.githubusercontent.com/");
    raw.push_str(owner);
    raw.push('/');
    raw.push_str(repo);
    raw.push('/');
    raw.push_str(branch);
    raw.push('/');
    raw.push_str(first_path);
    for segment in segments {
        raw.push('/');
        raw.push_str(segment);
    }
    Some(raw)
}

fn github_raw_path_mirror_to_raw(parsed: Url) -> Option<String> {
    let mut segments = parsed.path_segments()?;
    let owner = segments.next()?;
    let repo = segments.next()?;
    let branch = segments.next()?;
    let first_path = segments.next()?;
    let mut raw = String::with_capacity(parsed.as_str().len() + 16);
    raw.push_str("https://raw.githubusercontent.com/");
    raw.push_str(owner);
    raw.push('/');
    raw.push_str(repo);
    raw.push('/');
    raw.push_str(branch);
    raw.push('/');
    raw.push_str(first_path);
    for segment in segments {
        raw.push('/');
        raw.push_str(segment);
    }
    Some(raw)
}

fn github_contents_default_ref_to_base(url: &str) -> Option<String> {
    let parsed = Url::parse(url).ok()?;
    if !parsed.host_str()?.eq_ignore_ascii_case("api.github.com") {
        return None;
    }
    let mut segments = parsed.path_segments()?;
    if segments.next()? != "repos" {
        return None;
    }
    let owner = segments.next()?;
    let repo = segments.next()?;
    if segments.next()? != "contents" {
        return None;
    }
    let mut url = format!("https://api.github.com/repos/{owner}/{repo}/contents");
    for segment in segments {
        url.push('/');
        url.push_str(segment);
    }
    let mut pairs = parsed.query_pairs();
    let (key, value) = pairs.next()?;
    if pairs.next().is_some() || key != "ref" || !is_default_github_branch(&value) {
        return None;
    }
    Some(url)
}

fn is_default_github_branch(value: &str) -> bool {
    value.eq_ignore_ascii_case("main") || value.eq_ignore_ascii_case("master")
}

fn github_discovery_candidates(seed: &str) -> Vec<String> {
    let Some((owner, repo, seed_branch)) = github_seed_parts(seed) else {
        return Vec::new();
    };
    let mut urls = Vec::with_capacity(if seed_branch.is_some() { 6 } else { 4 });
    urls.push(format!("https://api.github.com/repos/{owner}/{repo}"));
    urls.push(format!(
        "https://api.github.com/repos/{owner}/{repo}/contents"
    ));
    if let Some(branch) = seed_branch.as_deref() {
        urls.push(format!(
            "https://api.github.com/repos/{owner}/{repo}/contents?ref={branch}"
        ));
        urls.push(format!(
            "https://api.github.com/repos/{owner}/{repo}/git/trees/{branch}?recursive=1"
        ));
    }
    urls.push(format!(
        "https://api.github.com/repos/{owner}/{repo}/git/trees/main?recursive=1"
    ));
    urls.push(format!(
        "https://api.github.com/repos/{owner}/{repo}/git/trees/master?recursive=1"
    ));
    urls
}

fn github_raw_seed_candidates(seed: &str) -> Vec<String> {
    let Some((owner, repo, seed_branch)) = github_seed_parts(seed) else {
        return Vec::new();
    };
    let branch_count = if seed_branch.is_some() { 3 } else { 2 };
    let mut urls = Vec::with_capacity(branch_count * GITHUB_RAW_SEED_PATHS.len() + 2);
    if let Some(branch) = seed_branch.as_deref() {
        for path in GITHUB_RAW_SEED_PATHS {
            urls.push(raw_github_url(&owner, &repo, branch, path));
        }
    }
    for branch in ["main", "master"] {
        for path in GITHUB_RAW_SEED_PATHS {
            urls.push(raw_github_url(&owner, &repo, branch, path));
        }
    }
    if owner.eq_ignore_ascii_case("crossxx-labs") && repo.eq_ignore_ascii_case("free-proxy") {
        urls.push("http://clash.crossxx.com/".to_string());
        urls.push("https://www.freeclash.top/ui/free_clash".to_string());
    }
    urls
}

fn github_seed_parts(seed: &str) -> Option<(String, String, Option<String>)> {
    let canonical = canonical_fetch_key(seed);
    github_seed_parts_from_url(&canonical).or_else(|| github_seed_parts_from_url(seed))
}

fn github_seed_parts_from_url(url: &str) -> Option<(String, String, Option<String>)> {
    let uri = Url::parse(url).ok()?;
    let host = uri.host_str()?;
    let mut segments = uri.path_segments()?;
    if host.eq_ignore_ascii_case("api.github.com") {
        if segments.next()? != "repos" {
            return None;
        }
        let api_owner = segments.next()?.to_string();
        let api_repo = segments.next()?.to_string();
        return Some((api_owner, api_repo, None));
    }
    let is_raw_github = host.eq_ignore_ascii_case("raw.githubusercontent.com");
    let is_github = host.eq_ignore_ascii_case("github.com");
    if !is_raw_github && !is_github {
        return None;
    }
    let owner = segments.next()?.to_string();
    let repo = segments.next()?.to_string();
    if is_raw_github {
        let branch = segments.next().and_then(non_default_github_seed_branch);
        return Some((owner, repo, branch));
    }
    if is_github {
        let branch = match segments.next() {
            Some("blob") => segments.next().and_then(non_default_github_seed_branch),
            _ => None,
        };
        return Some((owner, repo, branch));
    }
    None
}

fn non_default_github_seed_branch(branch: &str) -> Option<String> {
    let branch = branch.trim();
    if branch.is_empty()
        || branch.eq_ignore_ascii_case("main")
        || branch.eq_ignore_ascii_case("master")
        || branch.eq_ignore_ascii_case("refs")
    {
        return None;
    }
    Some(branch.to_string())
}

#[cfg(test)]
fn first_github_mirror_url(url: &str) -> Option<String> {
    nth_github_mirror_url(url, 0)
}

#[cfg(test)]
fn nth_github_mirror_url(url: &str, mirror_index: usize) -> Option<String> {
    if !is_github_mirrorable_url(url) {
        return None;
    }
    unchecked_github_mirror_url(url, mirror_index)
}

#[cfg(test)]
fn unchecked_github_mirror_url(url: &str, mirror_index: usize) -> Option<String> {
    let prefix = *GITHUB_RAW_MIRROR_PREFIXES.get(mirror_index)?;
    Some(github_raw_mirror_url_from_prefix(prefix, url))
}

fn github_raw_mirror_url_from_prefix(prefix: &str, url: &str) -> String {
    let mut mirror = String::with_capacity(prefix.len() + url.len());
    mirror.push_str(prefix);
    mirror.push_str(url);
    mirror
}

#[cfg(test)]
fn nth_github_path_mirror_url(url: &str, mirror_index: usize) -> Option<String> {
    let prefix = *GITHUB_PATH_MIRROR_PREFIXES.get(mirror_index)?;
    let suffix = github_path_mirror_suffix(url)?;
    Some(github_path_mirror_url_from_suffix(prefix, &suffix))
}

#[cfg(test)]
fn nth_github_raw_path_mirror_url(url: &str, mirror_index: usize) -> Option<String> {
    let prefix = *GITHUB_RAW_PATH_MIRROR_PREFIXES.get(mirror_index)?;
    let path_suffix = github_path_mirror_suffix(url)?;
    github_raw_path_mirror_url_from_path_suffix(prefix, &path_suffix)
}

fn github_path_mirror_suffix(url: &str) -> Option<String> {
    let parsed = Url::parse(url).ok()?;
    if !parsed
        .host_str()?
        .eq_ignore_ascii_case("raw.githubusercontent.com")
    {
        return None;
    }
    let mut segments = parsed.path_segments()?;
    let owner = segments.next()?;
    let repo = segments.next()?;
    let mut branch = segments.next()?;
    let mut first_path = segments.next()?;
    if branch == "refs" && first_path == "heads" {
        branch = segments.next()?;
        first_path = segments.next()?;
    }
    let path_capacity = parsed.path().len().saturating_sub(1);
    let mut suffix = String::with_capacity(path_capacity);
    suffix.push_str(owner);
    suffix.push('/');
    suffix.push_str(repo);
    suffix.push('@');
    suffix.push_str(branch);
    suffix.push('/');
    suffix.push_str(first_path);
    for segment in segments {
        suffix.push('/');
        suffix.push_str(segment);
    }
    Some(suffix)
}

fn github_path_mirror_url_from_suffix(prefix: &str, suffix: &str) -> String {
    let mut mirror = String::with_capacity(prefix.len() + suffix.len());
    mirror.push_str(prefix);
    mirror.push_str(suffix);
    mirror
}

fn github_raw_path_mirror_url_from_path_suffix(prefix: &str, suffix: &str) -> Option<String> {
    let marker = suffix.find('@')?;
    let mut mirror = String::with_capacity(prefix.len() + suffix.len());
    mirror.push_str(prefix);
    mirror.push_str(&suffix[..marker]);
    mirror.push('/');
    mirror.push_str(&suffix[marker + 1..]);
    Some(mirror)
}

fn has_github_mirrorable_host_hint(url: &str) -> bool {
    contains_ascii_case_insensitive(url, "raw.githubusercontent.com")
        || contains_ascii_case_insensitive(url, "api.github.com")
}

fn is_github_mirrorable_url(url: &str) -> bool {
    if !has_github_mirrorable_host_hint(url) {
        return false;
    }
    let Ok(uri) = Url::parse(url) else {
        return false;
    };
    let Some(host) = uri.host_str() else {
        return false;
    };
    if !host.eq_ignore_ascii_case("raw.githubusercontent.com")
        && !host.eq_ignore_ascii_case("api.github.com")
    {
        return false;
    }
    !GITHUB_RAW_MIRROR_PREFIXES
        .iter()
        .any(|prefix| starts_with_ascii_case_insensitive(url, prefix))
}

#[cfg(test)]
fn github_mirror_urls(url: &str) -> Vec<String> {
    if !is_github_mirrorable_url(url) {
        return Vec::new();
    }
    let mut mirrors: Vec<String> = GITHUB_RAW_MIRROR_PREFIXES
        .iter()
        .map(|prefix| {
            let mut mirror = String::with_capacity(prefix.len() + url.len());
            mirror.push_str(prefix);
            mirror.push_str(url);
            mirror
        })
        .collect();
    mirrors.extend(
        (0..GITHUB_PATH_MIRROR_PREFIXES.len())
            .filter_map(|mirror_index| nth_github_path_mirror_url(url, mirror_index)),
    );
    mirrors.extend(
        (0..GITHUB_RAW_PATH_MIRROR_PREFIXES.len())
            .filter_map(|mirror_index| nth_github_raw_path_mirror_url(url, mirror_index)),
    );
    mirrors
}

fn date_label_from_token(token: i64) -> String {
    let year = token / 10000;
    let month = (token / 100) % 100;
    let day = token % 100;
    format!("{FREE_NODES_DATE_GROUP_PREFIX}{year:04}-{month:02}-{day:02}")
}

fn date_token(url: &str) -> i64 {
    date_token_from_text(url).unwrap_or(0)
}

fn date_token_from_text(text: &str) -> Option<i64> {
    let bytes = text.as_bytes();
    for index in 0..bytes.len().saturating_sub(7) {
        if bytes[index] != b'2' || bytes[index + 1] != b'0' {
            continue;
        }
        let mut token = 0_i64;
        let mut digit_count = 0;
        let mut cursor = index;
        while cursor < bytes.len() && digit_count < 8 {
            let byte = bytes[cursor];
            if byte.is_ascii_digit() {
                token = token * 10 + i64::from(byte - b'0');
                digit_count += 1;
            } else if matches!(byte, b'-' | b'_' | b'/' | b'.') {
            } else {
                break;
            }
            cursor += 1;
        }
        if digit_count == 8 && is_valid_date_token(token) {
            return Some(token);
        }
    }
    None
}

fn is_valid_date_token(token: i64) -> bool {
    let year = token / 10000;
    let month = (token / 100) % 100;
    let day = token % 100;
    if year < 2000 || !(1..=12).contains(&month) {
        return false;
    }
    let max_day = match month {
        1 | 3 | 5 | 7 | 8 | 10 | 12 => 31,
        4 | 6 | 9 | 11 => 30,
        2 if is_leap_year(year) => 29,
        2 => 28,
        _ => return false,
    };
    (1..=max_day).contains(&day)
}

fn is_leap_year(year: i64) -> bool {
    (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
}

fn date_token_from_label(label: &str) -> i64 {
    date_token_from_text(label).unwrap_or(0)
}

fn normalize_date_group_label(label: &str) -> String {
    if label == FREE_NODES_LEGACY_TREASURE_GROUP_NAME {
        return FREE_NODES_TREASURE_GROUP_NAME.to_string();
    }
    if label == FREE_NODES_HISTORY_GROUP_NAME || is_free_nodes_treasure_group(label) {
        return label.to_string();
    }
    let token = date_token_from_label(label);
    if token > 0 {
        date_label_from_token(token)
    } else {
        label.to_string()
    }
}

fn day_number_from_token(token: i64) -> Option<i64> {
    let year = token / 10000;
    let month = (token / 100) % 100;
    let day = token % 100;
    if !is_valid_date_token(token) {
        return None;
    }
    Some(days_from_civil(year, month, day))
}

fn days_from_civil(year: i64, month: i64, day: i64) -> i64 {
    let year = year - if month <= 2 { 1 } else { 0 };
    let era = if year >= 0 { year } else { year - 399 } / 400;
    let yoe = year - era * 400;
    let month_prime = month + if month > 2 { -3 } else { 9 };
    let doy = (153 * month_prime + 2) / 5 + day - 1;
    let doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
    era * 146097 + doe - 719468
}

fn is_free_nodes_treasure_group(name: &str) -> bool {
    name == FREE_NODES_TREASURE_GROUP_NAME || name == FREE_NODES_LEGACY_TREASURE_GROUP_NAME
}

fn source_label_from_group_name(name: &str) -> Option<String> {
    let label = name
        .trim()
        .strip_prefix(FREE_NODES_SOURCE_GROUP_PREFIX)?
        .trim();
    (!label.is_empty()).then(|| label.to_string())
}

fn percent_decode(value: &str) -> String {
    let bytes = value.as_bytes();
    let mut out = Vec::with_capacity(bytes.len());
    let mut index = 0;
    while index < bytes.len() {
        if bytes[index] == b'%' && index + 2 < bytes.len() {
            if let Ok(hex) = u8::from_str_radix(&value[index + 1..index + 3], 16) {
                out.push(hex);
                index += 3;
                continue;
            }
        }
        out.push(bytes[index]);
        index += 1;
    }
    String::from_utf8(out).unwrap_or_else(|_| value.to_string())
}

#[cfg(test)]
mod tests {

    #[test]
    fn test_adaptive_source_worker_count_scales_without_fixed_global_cap() {
        let low_parallelism = adaptive_source_worker_count(187, 187, 8);
        let high_parallelism = adaptive_source_worker_count(187, 187, 32);
        assert_eq!(low_parallelism, 10);
        assert_eq!(high_parallelism, 40);
        assert!(low_parallelism < 187);
        assert!(high_parallelism > low_parallelism);
        assert!(high_parallelism <= 187);
        assert_eq!(adaptive_source_worker_count(8, 187, 32), 8);
        assert_eq!(adaptive_source_worker_count(187, 0, 32), 0);
    }

    #[test]
    fn test_adaptive_source_worker_count_never_exceeds_source_count() {
        for source_count in 1..=187 {
            let workers = adaptive_source_worker_count(usize::MAX, source_count, 16);
            assert!((1..=source_count).contains(&workers));
        }
    }
    use super::*;

    #[test]
    fn test_cookie_header_from_set_cookie_values_streams_without_empty_segments() {
        let values = [
            "session=abc; Path=/; HttpOnly",
            "",
            "verify=ok; Max-Age=60",
            "theme=dark",
        ];

        assert_eq!(
            cookie_header_from_set_cookie_values(values.into_iter()),
            "session=abc; verify=ok; theme=dark"
        );
    }

    #[test]
    fn test_uri_query_param_helpers_scan_without_collecting_param_map() {
        let uri = Url::parse(
            "anytls://user:pass@example.com:443?empty=&hpkp=chrome&sni=sni.example.com&insecure=1&udp=true",
        )
        .expect("uri");

        assert_eq!(
            uri_query_param_value(&uri, &["missing", "sni"]).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            uri_query_param_value(&uri, &["empty", "hpkp"]).as_deref(),
            Some("chrome")
        );
        assert!(uri_query_bool_param(&uri, &["udp"]));
        assert!(uri_query_exact_param(&uri, "insecure", "1"));
        assert!(!uri_query_bool_param(&uri, &["empty", "missing"]));
    }

    #[test]
    fn test_insert_uri_query_helpers_write_clash_fields_without_param_map() {
        let uri = Url::parse(
            "tuic://user:pass@example.com:443?fp=chrome&allow_insecure=true&heartbeat_interval=3000&alpn=h3,h4",
        )
        .expect("uri");
        let mut proxy = Map::new();

        insert_uri_param(&mut proxy, &uri, "fingerprint", &["fingerprint", "fp"]);
        insert_uri_bool_param(&mut proxy, &uri, "skip-cert-verify", &["allow_insecure"]);
        insert_uri_int_param(
            &mut proxy,
            &uri,
            "heartbeat-interval",
            &["heartbeat_interval"],
        );
        insert_uri_alpn_param(&mut proxy, &uri);

        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("chrome")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("heartbeat-interval").and_then(Value::as_i64),
            Some(3000)
        );
        assert_eq!(
            proxy
                .get("alpn")
                .and_then(Value::as_array)
                .expect("alpn")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["h3".to_string(), "h4".to_string()]
        );
    }

    #[test]
    fn test_insert_uri_csv_helper_writes_arrays_without_param_map() {
        let uri = Url::parse(
            "ssh://root@example.com:22?host-key=key-a%2Ckey-b&empty=&dns=1.1.1.1,8.8.8.8",
        )
        .expect("uri");
        let mut proxy = Map::new();

        insert_uri_csv_param(&mut proxy, &uri, "host-key", &["host-key"]);
        insert_uri_csv_param(&mut proxy, &uri, "missing", &["empty", "missing"]);
        insert_uri_csv_param(&mut proxy, &uri, "dns", &["dns"]);

        assert_eq!(
            proxy
                .get("host-key")
                .and_then(Value::as_array)
                .expect("host-key")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["key-a".to_string(), "key-b".to_string()]
        );
        assert_eq!(
            proxy
                .get("dns")
                .and_then(Value::as_array)
                .expect("dns")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["1.1.1.1".to_string(), "8.8.8.8".to_string()]
        );
        assert!(!proxy.contains_key("missing"));
    }

    #[test]
    fn test_uri_proxy_parsers_do_not_collect_query_params_into_hashmap() {
        let source = include_str!("free_nodes.rs");
        let collect_call = concat!("uri.query_pairs().", "into_owned().", "collect()");

        assert!(
            !source.contains(collect_call),
            "URI proxy parsers should scan query params on demand"
        );
    }

    #[test]
    fn test_uri_query_helpers_scan_query_pairs_once_per_lookup() {
        let source = include_str!("free_nodes.rs");

        assert!(
            !source.contains("input_keys.iter().find_map(|input_key| {\n        uri.query_pairs()"),
            "uri_query_param_value should scan the query once and keep key priority"
        );
        assert!(
            !source.contains("input_keys.iter().any(|input_key| {\n        uri.query_pairs()"),
            "uri_query_bool_param should scan the query once"
        );
    }

    #[test]
    fn test_uri_query_param_value_preserves_key_priority_with_single_scan() {
        let uri = Url::parse("vless://uuid@example.com:443?sni=low.example&host=high.example")
            .expect("uri");

        assert_eq!(
            uri_query_param_value(&uri, &["host", "sni"]).as_deref(),
            Some("high.example")
        );
        assert!(!uri_query_bool_param(&uri, &["tls", "security"]));
    }

    #[test]
    fn test_uri_query_param_value_defers_owned_allocation_until_final_match() {
        let source = include_str!("free_nodes.rs");
        let string_best = concat!("None::<", "(usize, String)", ">");
        let eager_owned_best = concat!("best = Some((priority, ", "value.into_owned()", "))");

        assert!(
            !source.contains(string_best),
            "uri query selection should not allocate String for temporary best matches"
        );
        assert!(
            !source.contains(eager_owned_best),
            "uri query selection should store Cow while scanning and own only the final result"
        );
    }

    #[test]
    fn test_uri_query_param_priority_avoids_iterator_position_in_hot_path() {
        let source = include_str!("free_nodes.rs");
        let iterator_position =
            concat!(".position(", "|input_key| key.as_ref() == *input_key", ")");

        assert!(
            !source.contains(iterator_position),
            "URI query priority lookup should avoid iterator-position closure overhead in the hot path"
        );
    }

    #[test]
    fn test_array_param_helpers_do_not_collect_before_json_conversion() {
        let source = include_str!("free_nodes.rs");

        assert!(
            !source.contains(concat!("let items = value", "\n        .split(',')")),
            "CSV helpers should build JSON arrays directly instead of collecting an intermediate slice vec"
        );
        assert!(
            !source.contains(concat!("let alpn = value", "\n        .split(',')")),
            "ALPN helpers should build JSON arrays directly instead of collecting an intermediate slice vec"
        );
        let sing_box_collect = concat!(
            "alpn.iter().",
            "filter_map(string_value).",
            "collect::<Vec<_>>()"
        );
        assert!(
            !source.contains(sing_box_collect),
            "sing-box ALPN conversion should avoid an intermediate Vec before JSON insertion"
        );
    }

    #[test]
    fn test_parse_proxies_reuses_first_non_empty_result_vec() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn count_usable_proxies").next())
            .expect("parse_proxies body");

        assert!(
            body.contains("let mut proxies = Option::<Vec<Map<String, Value>>>::None;"),
            "parse_proxies should lazily initialize its output Vec"
        );
        assert!(
            body.contains("let parsed = parse_yaml_proxies(candidate);")
                && body.contains("append_parsed_proxies(&mut proxies, parsed);"),
            "parse_proxies should funnel YAML results through first-Vec reuse"
        );
        assert!(
            body.contains("let parsed = parse_uri_proxies(candidate);")
                && body.contains("parsed_uri = !parsed.is_empty();")
                && body.contains("append_parsed_proxies(&mut proxies, parsed);"),
            "parse_proxies should funnel URI results through first-Vec reuse"
        );
        assert!(
            body.contains(
                "append_parsed_proxies(&mut proxies, parse_uri_first_column_csv_proxies(candidate));"
            ),
            "parse_proxies should funnel URI CSV results through first-Vec reuse"
        );
        assert!(
            !body.contains("let mut proxies = Vec::new();"),
            "parse_proxies should not allocate an empty output Vec before the first non-empty parse"
        );
    }

    #[test]
    fn test_proxy_uri_hint_reuses_text_bytes_in_scan_loop() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn proxy_uri_hint_with_schemes")
            .nth(1)
            .and_then(|rest| rest.split("fn decode_base64_text").next())
            .expect("proxy_uri_hint_with_schemes body");

        assert!(
            body.contains("let text_bytes = text.as_bytes();"),
            "URI hint scanning should cache text.as_bytes() once before the hot loop"
        );
        assert!(
            body.contains("text_bytes[cursor]"),
            "URI hint scanning should use the cached byte slice for cursor checks"
        );
        assert!(
            !body.contains("text.as_bytes()[cursor]"),
            "URI hint scanning should not repeatedly call text.as_bytes() in the hot loop"
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_clash_list() {
        let text = r#"
proxies:
  - name: test
    type: ss
    server: example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
  - name: unsupported-socks4
    type: socks4
    server: 198.51.100.41
    port: 1080
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("example.com")
        );
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("198.51.100.41")
        }));
    }

    #[test]
    fn test_parse_yaml_proxies_reads_named_proxy_map() {
        let text = r#"
proxies:
  map-ss:
    type: ss
    server: map-ss.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
  explicit-name:
    name: kept-name
    type: trojan
    server: map-trojan.example.com
    port: 443
    password: secret
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("name").and_then(string_value).as_deref() == Some("map-ss")
                && proxy.get("server").and_then(string_value).as_deref()
                    == Some("map-ss.example.com")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("name").and_then(string_value).as_deref() == Some("kept-name")
                && proxy.get("server").and_then(string_value).as_deref()
                    == Some("map-trojan.example.com")
        }));
    }

    #[test]
    fn test_parse_yaml_proxies_reads_legacy_clash_proxy_key() {
        let text = r#"
Proxy:
  - name: legacy-proxy
    type: ss
    server: legacy-proxy.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("legacy-proxy")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("legacy-proxy.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_case_variant_top_level_proxy_keys() {
        let text = r#"
Proxies:
  - name: case-proxy
    type: ss
    server: case-proxy.example.com
    port: 443
    cipher: aes-128-gcm
    password: pass
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("case-proxy")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("case-proxy.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_case_variant_top_level_outbounds_key() {
        let text = r#"
Outbounds:
  - type: shadowsocks
    tag: Case Outbound
    server: case-outbound.example.com
    server_port: 8388
    method: aes-128-gcm
    password: pass
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("Case Outbound")
        );
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("ss")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("case-outbound.example.com")
        );
    }

    #[test]
    fn test_parse_proxies_normalizes_legacy_ss_chacha20_poly1305_cipher() {
        let yaml_text = r#"
proxies:
  - name: legacy-yaml
    type: ss
    server: legacy-yaml.example.com
    port: 443
    cipher: chacha20-poly1305
    password: pass
"#;
        let uri_text = "ss://chacha20-poly1305:pass@legacy-uri.example.com:8388#legacy-uri";

        let mut proxies = parse_proxies(yaml_text);
        proxies.extend(parse_proxies(uri_text));

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().all(|proxy| {
            proxy.get("cipher").and_then(string_value).as_deref() == Some("chacha20-ietf-poly1305")
        }));
    }

    #[test]
    fn test_parse_yaml_proxies_preallocates_output_from_yaml_array_lengths() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_yaml_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn normalize_proxy_value").next())
            .expect("parse_yaml_proxies body");

        assert!(
            body.contains("Vec::<Map<String, Value>>::with_capacity(raw.len())"),
            "root YAML proxy arrays should preallocate output to the source array length"
        );
        assert!(
            body.contains("let raw_proxies = remove_first_yaml_key"),
            "object YAML parsing should extract proxies before sizing the output buffer"
        );
        assert!(
            body.contains("let raw_outbounds =")
                && body.contains("remove_first_yaml_key(&mut object, &[\"outbounds\"]"),
            "object YAML parsing should extract outbounds before sizing the output buffer"
        );
        assert!(
            body.contains("let proxy_capacity")
                && body.contains("raw_proxies.as_ref().map_or(0, Vec::len)")
                && body.contains("raw_outbounds.as_ref().map_or(0, Vec::len)"),
            "object YAML parsing should size output from proxies and outbounds array lengths"
        );
        assert!(
            body.contains("Vec::<Map<String, Value>>::with_capacity(proxy_capacity)"),
            "object YAML parsing should preallocate output to the combined source array length"
        );
        assert!(
            !body.contains("let mut proxies = Vec::new();"),
            "parse_yaml_proxies should not start from an empty output Vec"
        );
    }

    #[test]
    fn test_remove_first_yaml_key_uses_exact_match_before_case_fallback() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn remove_first_yaml_key")
            .nth(1)
            .and_then(|rest| rest.split("fn proxy_map_values").next())
            .expect("remove_first_yaml_key body");

        let exact_index = body.find("object.remove(*key)").expect("exact key removal");
        let fallback_index = body
            .find("eq_ignore_ascii_case")
            .expect("case-insensitive fallback");
        assert!(
            exact_index < fallback_index,
            "YAML key removal should preserve the exact-key hot path before case-insensitive fallback"
        );

        let mut object = Map::new();
        object.insert("Proxies".into(), json!([]));
        assert!(remove_first_yaml_key(&mut object, &["proxies"]).is_some());
    }

    #[test]
    fn test_parse_yaml_proxies_reads_root_proxy_list() {
        let text = r#"
- name: root-ss
  type: ss
  server: root-ss.example.com
  port: 443
  cipher: aes-128-gcm
  password: pass
- name: root-trojan
  type: trojan
  server: root-trojan.example.com
  port: 443
  password: secret
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("root-ss.example.com")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("root-trojan.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_root_json_proxy_list() {
        let text = r#"
[
  {
    "name": "json-ss",
    "type": "ss",
    "server": "json-ss.example.com",
    "port": 443,
    "cipher": "aes-128-gcm",
    "password": "pass"
  },
  {
    "name": "json-trojan",
    "type": "trojan",
    "server": "json-trojan.example.com",
    "port": 443,
    "password": "secret"
  }
]
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("json-ss.example.com")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("json-trojan.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_root_json_sing_box_outbound_list() {
        let text = r#"
[
  {
    "type": "shadowsocks",
    "tag": "Root SS Out",
    "server": "root-ss-out.example.com",
    "server_port": 8388,
    "method": "aes-128-gcm",
    "password": "ss-pass"
  },
  {
    "type": "vless",
    "tag": "Root VLESS Out",
    "server": "root-vless-out.example.com",
    "server_port": 443,
    "uuid": "00000000-0000-0000-0000-000000000000",
    "tls": { "enabled": true, "server_name": "root-sni.example.com" }
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("Root SS Out")
        );
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("ss")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("root-ss-out.example.com")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8388));
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("vless")
        );
        assert_eq!(
            proxies[1].get("sni").and_then(string_value).as_deref(),
            Some("root-sni.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_root_yaml_sing_box_outbound_list() {
        let text = r#"
- type: shadowsocks
  tag: Root YAML SS Out
  server: root-yaml-ss-out.example.com
  server_port: 8388
  method: aes-128-gcm
  password: ss-pass
- type: trojan
  tag: Root YAML Trojan Out
  server: root-yaml-trojan-out.example.com
  server_port: 443
  password: trojan-pass
  tls:
    enabled: true
    server_name: root-yaml-sni.example.com
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("Root YAML SS Out")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("root-yaml-ss-out.example.com")
        );
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("trojan")
        );
        assert_eq!(
            proxies[1].get("sni").and_then(string_value).as_deref(),
            Some("root-yaml-sni.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_root_json_sing_box_port_alias() {
        let text = r#"
[
  {
    "type": "vless",
    "tag": "Root Port VLESS Out",
    "server": "root-port-vless.example.com",
    "port": 443,
    "uuid": "00000000-0000-0000-0000-000000000000",
    "tls": { "enabled": true, "server_name": "root-port-sni.example.com" }
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("Root Port VLESS Out")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("root-port-vless.example.com")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxies[0].get("sni").and_then(string_value).as_deref(),
            Some("root-port-sni.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_root_yaml_sing_box_port_alias() {
        let text = r#"
- type: trojan
  tag: Root YAML Port Trojan Out
  server: root-yaml-port-trojan.example.com
  port: 443
  password: trojan-pass
  tls:
    enabled: true
    server_name: root-yaml-port-sni.example.com
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("Root YAML Port Trojan Out")
        );
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("trojan")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("root-yaml-port-trojan.example.com")
        );
        assert_eq!(
            proxies[0].get("sni").and_then(string_value).as_deref(),
            Some("root-yaml-port-sni.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_root_sing_box_port_alias_without_tag() {
        let text = r#"
[
  {
    "type": "shadowsocks",
    "server": "root-port-no-tag.example.com",
    "port": 8388,
    "method": "aes-128-gcm",
    "password": "ss-pass"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("ss-root-port-no-tag.example.com")
        );
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("ss")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("root-port-no-tag.example.com")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8388));
    }

    #[test]
    fn test_parse_proxies_reads_decimal_ascii_byte_stream() {
        let text = "116 114 111 106 97 110 58 47 47 112 97 115 115 64 100 101 99 105 109 97 108 46 101 120 97 109 112 108 101 46 99 111 109 58 52 52 51 35 68 101 99 105 109 97 108";

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("trojan")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("decimal.example.com")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(443));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_json_array() {
        let text = r#"
[
  {
    "proxy": "socks5://208.102.51.6:58208",
    "protocol": "socks5",
    "ip": "208.102.51.6",
    "port": 58208,
    "country": "ZZ"
  },
  {
    "proxy": "socks4://72.49.49.11:31034",
    "protocol": "socks4",
    "ip": "72.49.49.11",
    "port": 31034
  },
  {
    "protocol": "http",
    "ip": "83.222.18.131",
    "port": 8080,
    "ssl": true
  },
  {
    "protocol": "https",
    "ip": "84.17.47.150",
    "port": 9002
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("socks5-208.102.51.6:58208")
        );
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(58208));
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("72.49.49.11")
        }));
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("http-83.222.18.131:8080")
        );
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            proxies[2].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
    }

    #[test]
    fn test_parse_proxies_reads_wrapped_generic_proxy_list_json_arrays() {
        let text = r#"
{
  "data": [
    {
      "protocol": "http",
      "ip": "131.222.252.72",
      "port": 8080,
      "ssl": true
    }
  ],
  "results": [
    {
      "proxy": "socks5://69.61.200.104:36181",
      "protocol": "socks5"
    }
  ],
  "items": [
    {
      "protocol": "https",
      "host": "secure-proxy.example.com",
      "port": 9002
    }
  ]
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-131.222.252.72:8080")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-69.61.200.104:36181")
        );
        assert_eq!(
            proxies[2].get("name").and_then(string_value).as_deref(),
            Some("http-secure-proxy.example.com:9002")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_json_alias_fields() {
        let text = r#"
[
  {
    "type": "http",
    "address": "198.51.100.10",
    "port": "8080"
  },
  {
    "scheme": "socks5",
    "addr": "socks-alias.example.com",
    "port": 1080
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-198.51.100.10:8080")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.10")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-socks-alias.example.com:1080")
        );
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_extended_alias_fields() {
        let text = r#"
[
  {
    "proxyType": "http",
    "domain": "domain-proxy.example.com",
    "serverPort": "8080"
  },
  {
    "proxy_type": "socks5",
    "host": "198.51.100.101",
    "remote_port": 1080
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-domain-proxy.example.com:8080")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-198.51.100.101:1080")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_host_port_proxy_field() {
        let text = r#"
[
  {
    "protocol": "socks5",
    "proxy": "203.0.113.10:1080"
  },
  {
    "scheme": "https",
    "proxy": "edge.example.com:8443",
    "name": "edge-http"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("203.0.113.10")
        );
        assert_eq!(proxies[0].get("port").and_then(Value::as_i64), Some(1080));
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge.example.com")
        );
        assert_eq!(proxies[1].get("port").and_then(Value::as_i64), Some(8443));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_host_port_server_aliases() {
        let text = r#"
[
  {
    "protocol": "socks5",
    "host": "203.0.113.12:1080"
  },
  {
    "scheme": "https",
    "address": "edge-host-port.example.com:8443",
    "name": "edge-host-port"
  },
  {
    "type": "http",
    "server": "[2001:db8::1]:8080"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("203.0.113.12")
        );
        assert_eq!(proxies[0].get("port").and_then(Value::as_i64), Some(1080));
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.12:1080")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge-host-port.example.com")
        );
        assert_eq!(proxies[1].get("port").and_then(Value::as_i64), Some(8443));
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("edge-host-port")
        );
        assert_eq!(
            proxies[2].get("server").and_then(string_value).as_deref(),
            Some("2001:db8::1")
        );
        assert_eq!(proxies[2].get("port").and_then(Value::as_i64), Some(8080));
    }

    #[test]
    fn test_parse_proxies_skips_socks4_incompatible_proxy_records() {
        let text = r#"
[
  {"protocol": "socks4", "ip": "198.51.100.40", "port": 1080},
  {"protocol": "socks5", "ip": "198.51.100.50", "port": 1080},
  {"protocol": "http", "ip": "198.51.100.60", "port": 8080}
]
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("198.51.100.40")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("198.51.100.50")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("198.51.100.60")
        }));
    }

    #[test]
    fn test_parse_proxies_reads_plain_host_port_proxy_list() {
        let text = r#"
# plain free proxy list
198.51.100.10:8080
edge-plain.example.com:8443
[2001:db8::2]:1080
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.10")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("http-edge-plain.example.com:8443")
        );
        assert_eq!(
            proxies[2].get("server").and_then(string_value).as_deref(),
            Some("2001:db8::2")
        );
        assert_eq!(proxies[2].get("port").and_then(parse_port), Some(1080));
    }

    #[test]
    fn test_parse_proxies_reads_plain_authenticated_proxy_list() {
        let text = r#"
user-a:pass-a@198.51.100.20:8080
edge-auth.example.com:8443:user-b:pass-b
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.20")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[0].get("username").and_then(string_value).as_deref(),
            Some("user-a")
        );
        assert_eq!(
            proxies[0].get("password").and_then(string_value).as_deref(),
            Some("pass-a")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge-auth.example.com")
        );
        assert_eq!(proxies[1].get("port").and_then(parse_port), Some(8443));
        assert_eq!(
            proxies[1].get("username").and_then(string_value).as_deref(),
            Some("user-b")
        );
        assert_eq!(
            proxies[1].get("password").and_then(string_value).as_deref(),
            Some("pass-b")
        );
    }

    #[test]
    fn test_parse_proxies_reads_plain_auth_column_proxy_list() {
        let text = r#"
198.51.100.21 8080 user-a pass-a
edge-auth-column.example.com,8443,user-b,pass-b
edge-auth-column-semi.example.com;8444;user-c;pass-c
edge-auth-column-pipe.example.com|8445|user-d|pass-d
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 4);
        assert!(proxies
            .iter()
            .all(|proxy| proxy.get("type").and_then(string_value).as_deref() == Some("http")));
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.21")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[0].get("username").and_then(string_value).as_deref(),
            Some("user-a")
        );
        assert_eq!(
            proxies[0].get("password").and_then(string_value).as_deref(),
            Some("pass-a")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge-auth-column.example.com")
        );
        assert_eq!(
            proxies[1].get("username").and_then(string_value).as_deref(),
            Some("user-b")
        );
        assert_eq!(
            proxies[2].get("password").and_then(string_value).as_deref(),
            Some("pass-c")
        );
        assert_eq!(
            proxies[3].get("server").and_then(string_value).as_deref(),
            Some("edge-auth-column-pipe.example.com")
        );
        assert_eq!(proxies[3].get("port").and_then(parse_port), Some(8445));
        assert_eq!(
            proxies[3].get("password").and_then(string_value).as_deref(),
            Some("pass-d")
        );
    }

    #[test]
    fn test_parse_proxies_reads_plain_two_column_proxy_list() {
        let text = r#"
198.51.100.30 8080
edge-two-column.example.com,8443
2001:db8::3 1080
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.30")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge-two-column.example.com")
        );
        assert_eq!(proxies[1].get("port").and_then(parse_port), Some(8443));
        assert_eq!(
            proxies[2].get("server").and_then(string_value).as_deref(),
            Some("2001:db8::3")
        );
        assert_eq!(proxies[2].get("port").and_then(parse_port), Some(1080));
        assert!(proxies
            .iter()
            .all(|proxy| proxy.get("type").and_then(string_value).as_deref() == Some("http")));
    }

    #[test]
    fn test_parse_proxies_reads_plain_delimited_proxy_list() {
        let text = r#"
198.51.100.31;8080
edge-pipe.example.com|8443
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.31")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge-pipe.example.com")
        );
        assert_eq!(proxies[1].get("port").and_then(parse_port), Some(8443));
        assert!(proxies
            .iter()
            .all(|proxy| proxy.get("type").and_then(string_value).as_deref() == Some("http")));
    }

    #[test]
    fn test_parse_proxies_reads_plain_protocol_column_proxy_list() {
        let text = r#"
socks5 198.51.100.40 1080
198.51.100.41 8080 http
socks5,edge-protocol.example.com,1081
edge-semi.example.com;8081;http
http|edge-pipe-protocol.example.com|8082
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 5);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.40")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(1080));
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.41")
        );
        assert_eq!(proxies[1].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[2].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxies[2].get("server").and_then(string_value).as_deref(),
            Some("edge-protocol.example.com")
        );
        assert_eq!(proxies[2].get("port").and_then(parse_port), Some(1081));
        assert_eq!(
            proxies[3].get("server").and_then(string_value).as_deref(),
            Some("edge-semi.example.com")
        );
        assert_eq!(proxies[3].get("port").and_then(parse_port), Some(8081));
        assert_eq!(
            proxies[4].get("server").and_then(string_value).as_deref(),
            Some("edge-pipe-protocol.example.com")
        );
        assert_eq!(proxies[4].get("port").and_then(parse_port), Some(8082));
    }

    #[test]
    fn test_parse_proxies_skips_plain_unsupported_socks4_protocol_lines() {
        let text = r#"
socks4 198.51.100.44 1080
socks5 198.51.100.45 1081
198.51.100.46 8080 http
socks4,edge-socks4.example.com,1082
http,edge-http.example.com,8082
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert!(proxies.iter().all(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() != Some("198.51.100.44")
                && proxy.get("server").and_then(string_value).as_deref()
                    != Some("edge-socks4.example.com")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("198.51.100.45")
                && proxy.get("port").and_then(parse_port) == Some(1081)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("198.51.100.46")
                && proxy.get("port").and_then(parse_port) == Some(8080)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("edge-http.example.com")
                && proxy.get("port").and_then(parse_port) == Some(8082)
        }));
    }

    #[test]
    fn test_parse_proxies_reads_plain_protocol_auth_column_proxy_list() {
        let text = r#"
socks5 198.51.100.42 1080 user-a pass-a
198.51.100.43 8080 user-b pass-b http
socks5,edge-auth-protocol.example.com,1081,user-c,pass-c
edge-auth-semi.example.com;8081;user-d;pass-d;http
http|edge-auth-pipe.example.com|8082|user-e|pass-e
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 5);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("198.51.100.42")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(1080));
        assert_eq!(
            proxies[0].get("username").and_then(string_value).as_deref(),
            Some("user-a")
        );
        assert_eq!(
            proxies[0].get("password").and_then(string_value).as_deref(),
            Some("pass-a")
        );
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            proxies[1].get("username").and_then(string_value).as_deref(),
            Some("user-b")
        );
        assert_eq!(
            proxies[1].get("password").and_then(string_value).as_deref(),
            Some("pass-b")
        );
        assert_eq!(
            proxies[2].get("username").and_then(string_value).as_deref(),
            Some("user-c")
        );
        assert_eq!(
            proxies[3].get("password").and_then(string_value).as_deref(),
            Some("pass-d")
        );
        assert_eq!(
            proxies[4].get("server").and_then(string_value).as_deref(),
            Some("edge-auth-pipe.example.com")
        );
        assert_eq!(
            proxies[4].get("username").and_then(string_value).as_deref(),
            Some("user-e")
        );
    }

    #[test]
    fn test_parse_proxies_ignores_plain_text_with_non_proxy_lines() {
        let text = r#"
This page mentions an endpoint 198.51.100.10:8080 in prose.
updated: 2026-06-29
"#;

        assert!(parse_proxies(text).is_empty());
    }

    #[test]
    fn test_parse_proxies_reads_annotated_host_port_proxy_tokens() {
        let text = r#"
Proxy list updated at Fri, 24 Mar 23 07:58:01 +0300
IP address:Port CountryCode-Anonymity(Noa/Anm/Hia)-SSL_support(S)-Google_passed(+)
170.239.207.241:999 CO-N-S! + 42.2.156.79:80 HK-A + 181.39.24.152:999 EC-N-S -
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("170.239.207.241")
                && proxy.get("port").and_then(parse_port) == Some(999)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("42.2.156.79")
                && proxy.get("port").and_then(parse_port) == Some(80)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("181.39.24.152")
                && proxy.get("port").and_then(parse_port) == Some(999)
        }));
    }

    #[test]
    fn test_parse_proxies_reads_protocol_tag_xml_proxy_list() {
        let text = r#"
<SupplierProxyListData>
  <http>
    <http>1.0.205.87:8080</http>
    <http>1.1.189.58:8080</http>
  </http>
  <socks5>
    <socks5>72.195.101.99:4145</socks5>
  </socks5>
</SupplierProxyListData>
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("1.0.205.87")
                && proxy.get("port").and_then(parse_port) == Some(8080)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("72.195.101.99")
                && proxy.get("port").and_then(parse_port) == Some(4145)
        }));
    }

    #[test]
    fn test_parse_proxies_reads_xml_proxy_item_records() {
        let text = r#"
<response>
  <item id="0">
    <host>ip72-195-101-99.oc.oc.cox.net</host>
    <ip>72.195.101.99</ip>
    <port>4145</port>
    <http>0</http>
    <ssl>0</ssl>
    <socks4>1</socks4>
    <socks5>0</socks5>
  </item>
  <item>
    <ip>1.0.171.213</ip>
    <port>8080</port>
    <protocols>
      <protocols>
        <type>https</type>
        <port>8080</port>
      </protocols>
    </protocols>
  </item>
</response>
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("72.195.101.99")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("1.0.171.213")
                && proxy.get("port").and_then(parse_port) == Some(8080)
        }));
    }

    #[test]
    fn test_parse_proxies_reads_php_serialized_proxy_records() {
        let text = r#"a:2:{i:0;a:6:{s:4:"host";s:29:"ip72-195-101-99.oc.oc.cox.net";s:2:"ip";s:13:"72.195.101.99";s:4:"port";s:4:"4145";s:4:"http";s:1:"0";s:6:"socks4";s:1:"1";s:6:"socks5";s:1:"0";}i:1;a:6:{s:4:"host";s:11:"45.131.6.46";s:2:"ip";s:11:"45.131.6.46";s:4:"port";s:2:"80";s:4:"http";s:1:"1";s:6:"socks4";s:1:"0";s:6:"socks5";s:1:"0";}}"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("72.195.101.99")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("45.131.6.46")
                && proxy.get("port").and_then(parse_port) == Some(80)
        }));
    }

    #[test]
    fn test_parse_proxies_reads_uri_first_column_proxy_csv() {
        let text = r#"
socks5://208.102.51.6:58208,ZZ,Unknown
http://103.181.255.219:7777,ID,Unknown
socks5://208.102.51.6:58208,ZZ,Duplicate
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("208.102.51.6")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("103.181.255.219")
        }));
    }

    #[test]
    fn test_parse_proxies_ignores_non_proxy_csv_rows() {
        let text = r#"
url,country,city
https://example.com/page,US,Example
"#;

        assert!(parse_proxies(text).is_empty());
    }

    #[test]
    fn test_parse_proxies_reads_protocol_ip_port_csv_table() {
        let text = r#"
protocol,ip,port,country,country_code,city,anonymity,ssl,latency_ms
http,165.225.72.38,10423,Germany,DE,Frankfurt am Main,elite,true,124.73
socks5,161.97.79.227,9050,France,FR,Lauterbourg,elite,true,484.13
socks4,213.176.113.24,50001,The Netherlands,NL,Amsterdam,elite,true,78.47
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("165.225.72.38")
                && proxy.get("port").and_then(parse_port) == Some(10423)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("161.97.79.227")
                && proxy.get("port").and_then(parse_port) == Some(9050)
        }));
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("213.176.113.24")
        }));
    }

    #[test]
    fn test_parse_proxies_reads_protocol_host_port_csv_alias_headers() {
        let type_header_text = r#"
type,host,port,country
http,203.0.113.10,8080,US
"#;
        let scheme_header_text = r#"
scheme,server,port,country
socks5,203.0.113.11,1080,JP
"#;

        let mut proxies = parse_proxies(type_header_text);
        proxies.extend(parse_proxies(scheme_header_text));

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.10")
                && proxy.get("port").and_then(parse_port) == Some(8080)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.11")
                && proxy.get("port").and_then(parse_port) == Some(1080)
        }));
    }

    #[test]
    fn test_parse_proxies_reads_protocol_host_port_csv_aliases_in_any_first_three_order() {
        let host_port_type_text = r#"
host,port,type,country
203.0.113.20,8080,http,US
203.0.113.21,1080,socks4,US
"#;
        let ip_port_protocol_text = r#"
ip,port,protocol,country
203.0.113.22,1080,socks5,JP
"#;
        let address_port_scheme_text = r#"
address,port,scheme,country
203.0.113.23,8443,https,DE
"#;

        let mut proxies = parse_proxies(host_port_type_text);
        proxies.extend(parse_proxies(ip_port_protocol_text));
        proxies.extend(parse_proxies(address_port_scheme_text));

        assert_eq!(proxies.len(), 3);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.20")
                && proxy.get("port").and_then(parse_port) == Some(8080)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.22")
                && proxy.get("port").and_then(parse_port) == Some(1080)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.23")
                && proxy.get("port").and_then(parse_port) == Some(8443)
        }));
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.21")
        }));
    }

    #[test]
    fn test_parse_proxies_reads_protocol_csv_with_leading_metadata_columns() {
        let country_first_text = r#"
country,anonymity,protocol,ip,port,latency_ms
US,elite,http,203.0.113.30,8080,10
JP,elite,socks4,203.0.113.31,1081,11
"#;
        let latency_before_type_text = r#"
country,host,latency_ms,port,type
DE,203.0.113.32,24,1080,socks5
"#;

        let mut proxies = parse_proxies(country_first_text);
        proxies.extend(parse_proxies(latency_before_type_text));

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.30")
                && proxy.get("port").and_then(parse_port) == Some(8080)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.32")
                && proxy.get("port").and_then(parse_port) == Some(1080)
        }));
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.31")
        }));
    }

    #[test]
    fn test_parse_proxies_ignores_non_proxy_protocol_csv_table() {
        let text = r#"
protocol,ip,port
smtp,192.0.2.10,25
http,not a host,8080
"#;

        assert!(parse_proxies(text).is_empty());
    }

    #[test]
    fn test_parse_proxies_reads_protocol_column_proxy_csv_table() {
        let text = r#"
http,https,socks4,socks5
1.0.205.87:8080,1.0.171.213:8080,1.0.136.16:4153,1.12.55.136:2080
1.1.189.58:8080,,1.0.136.99:4145,1.180.0.162:7302
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 5);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("http")
                && proxy.get("server").and_then(string_value).as_deref() == Some("1.0.205.87")
                && proxy.get("port").and_then(parse_port) == Some(8080)
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("socks5")
                && proxy.get("server").and_then(string_value).as_deref() == Some("1.12.55.136")
                && proxy.get("port").and_then(parse_port) == Some(2080)
        }));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_protocol_arrays() {
        let text = r#"
[
  {
    "protocols": ["socks5", "http"],
    "ip": "203.0.113.20",
    "port": 1080
  },
  {
    "schemes": ["https"],
    "proxy": "edge-array.example.com:8443"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.20:1080")
        );
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("http-edge-array.example.com:8443")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge-array.example.com")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_protocol_aliases() {
        let text = r#"
[
  {
    "protocolType": "socks5",
    "server": "203.0.113.40",
    "port": 1080
  },
  {
    "proxy_protocol": "https",
    "host": "edge-protocol.example.com",
    "port": "8443"
  },
  {
    "proto": "socks4",
    "ip": "203.0.113.41",
    "port": 1081
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.40:1080")
        );
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("http-edge-protocol.example.com:8443")
        );
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.41")
        }));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_address_port_aliases() {
        let text = r#"
[
  {
    "protocol": "socks5",
    "ipAddress": "203.0.113.30",
    "portNumber": "1080"
  },
  {
    "scheme": "https",
    "proxy_address": "edge-alias.example.com",
    "proxy_port": 8443
  },
  {
    "type": "socks4",
    "serverAddress": "203.0.113.31",
    "port_number": 1081
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.30:1080")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("203.0.113.30")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(1080));
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("http-edge-alias.example.com:8443")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("edge-alias.example.com")
        );
        assert_eq!(proxies[1].get("port").and_then(parse_port), Some(8443));
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.31")
        }));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_port_arrays() {
        let text = r#"
[
  {
    "protocol": "http",
    "server": "ports.example.com",
    "ports": [8080, 8081]
  },
  {
    "scheme": "socks5",
    "host": "203.0.113.60",
    "portList": ["1080", "1081"]
  },
  {
    "type": "https",
    "address": "port-list.example.com",
    "port_list": ["", "8443"]
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-ports.example.com:8080")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.60:1080")
        );
        assert_eq!(proxies[1].get("port").and_then(parse_port), Some(1080));
        assert_eq!(
            proxies[2].get("name").and_then(string_value).as_deref(),
            Some("http-port-list.example.com:8443")
        );
        assert_eq!(proxies[2].get("port").and_then(parse_port), Some(8443));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_auth_fields() {
        let text = r#"
[
  {
    "protocol": "socks5",
    "server": "auth-socks.example.com",
    "port": 1080,
    "username": "socks-user",
    "password": "socks-pass"
  },
  {
    "scheme": "https",
    "host": "auth-http.example.com",
    "port": 8443,
    "user": "http-user",
    "pass": "http-pass"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("username").and_then(string_value).as_deref(),
            Some("socks-user")
        );
        assert_eq!(
            proxies[0].get("password").and_then(string_value).as_deref(),
            Some("socks-pass")
        );
        assert_eq!(
            proxies[1].get("username").and_then(string_value).as_deref(),
            Some("http-user")
        );
        assert_eq!(
            proxies[1].get("password").and_then(string_value).as_deref(),
            Some("http-pass")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_ssr_fields() {
        let text = r#"
[
  {
    "name": "SSR Generic",
    "type": "ssr",
    "server": "ssr-generic.example.com",
    "port": 8388,
    "cipher": "aes-256-cfb",
    "password": "secret",
    "protocol": "origin",
    "obfs": "plain",
    "obfs_param": "obfs.example.com",
    "protocol_param": "proto-param"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("ssr")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("ssr-generic.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(8388));
        assert_eq!(
            proxy.get("cipher").and_then(string_value).as_deref(),
            Some("aes-256-cfb")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("secret")
        );
        assert_eq!(
            proxy.get("protocol").and_then(string_value).as_deref(),
            Some("origin")
        );
        assert_eq!(
            proxy.get("obfs").and_then(string_value).as_deref(),
            Some("plain")
        );
        assert_eq!(
            proxy.get("obfs-param").and_then(string_value).as_deref(),
            Some("obfs.example.com")
        );
        assert_eq!(
            proxy
                .get("protocol-param")
                .and_then(string_value)
                .as_deref(),
            Some("proto-param")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_advanced_protocol_fields() {
        let text = r#"
[
  {
    "type": "shadowsocks",
    "server": "ss-generic.example.com",
    "serverPort": 8388,
    "method": "aes-128-gcm",
    "password": "ss-pass"
  },
  {
    "protocol": "vmess",
    "host": "vmess-generic.example.com",
    "port": 443,
    "id": "00000000-0000-0000-0000-000000000001",
    "security": "zero"
  },
  {
    "scheme": "vless",
    "address": "vless-generic.example.com",
    "proxyPort": 8443,
    "uuid": "00000000-0000-0000-0000-000000000002",
    "flow": "xtls-rprx-vision"
  },
  {
    "protocolType": "trojan",
    "proxyAddress": "trojan-generic.example.com",
    "portNumber": 443,
    "password": "trojan-pass"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 4);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("ss")
        );
        assert_eq!(
            proxies[0].get("cipher").and_then(string_value).as_deref(),
            Some("aes-128-gcm")
        );
        assert_eq!(
            proxies[0].get("password").and_then(string_value).as_deref(),
            Some("ss-pass")
        );
        assert_eq!(
            proxies[1].get("type").and_then(string_value).as_deref(),
            Some("vmess")
        );
        assert_eq!(
            proxies[1].get("uuid").and_then(string_value).as_deref(),
            Some("00000000-0000-0000-0000-000000000001")
        );
        assert_eq!(
            proxies[1].get("cipher").and_then(string_value).as_deref(),
            Some("zero")
        );
        assert_eq!(
            proxies[2].get("type").and_then(string_value).as_deref(),
            Some("vless")
        );
        assert_eq!(
            proxies[2].get("uuid").and_then(string_value).as_deref(),
            Some("00000000-0000-0000-0000-000000000002")
        );
        assert_eq!(
            proxies[2].get("flow").and_then(string_value).as_deref(),
            Some("xtls-rprx-vision")
        );
        assert_eq!(
            proxies[3].get("type").and_then(string_value).as_deref(),
            Some("trojan")
        );
        assert_eq!(
            proxies[3].get("password").and_then(string_value).as_deref(),
            Some("trojan-pass")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_vmess_alter_id_aliases() {
        let text = r#"
[
  {
    "protocol": "vmess",
    "host": "vmess-aid.example.com",
    "port": 443,
    "id": "00000000-0000-0000-0000-000000000011",
    "aid": 2
  },
  {
    "protocol": "vmess",
    "host": "vmess-alterid.example.com",
    "port": 8443,
    "id": "00000000-0000-0000-0000-000000000012",
    "alter_id": "4"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(proxies[0].get("alterId").and_then(parse_port), Some(2));
        assert_eq!(proxies[1].get("alterId").and_then(parse_port), Some(4));
        assert_eq!(
            proxies[0].get("cipher").and_then(string_value).as_deref(),
            Some("auto")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_runtime_fields() {
        let text = r#"
[
  {
    "scheme": "vless",
    "address": "vless-runtime.example.com",
    "proxyPort": 443,
    "uuid": "00000000-0000-0000-0000-000000000003",
    "tls": true,
    "sni": "vless-sni.example.com",
    "network": "ws",
    "path": "/edge",
    "host": "cdn.example.com",
    "skipCertVerify": true,
    "clientFingerprint": "chrome"
  },
  {
    "protocol": "trojan",
    "server": "trojan-runtime.example.com",
    "port": 443,
    "password": "trojan-pass",
    "servername": "trojan-sni.example.com",
    "transport": "websocket",
    "wsPath": "/trojan",
    "wsHost": "trojan-cdn.example.com",
    "allow_insecure": "1",
    "fp": "firefox"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        let vless = &proxies[0];
        assert_eq!(vless.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            vless.get("sni").and_then(string_value).as_deref(),
            Some("vless-sni.example.com")
        );
        assert_eq!(
            vless.get("servername").and_then(string_value).as_deref(),
            Some("vless-sni.example.com")
        );
        assert_eq!(
            vless.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            vless
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        assert_eq!(
            vless.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        let vless_ws_opts = vless
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("vless ws opts");
        assert_eq!(
            vless_ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/edge")
        );
        assert_eq!(
            vless_ws_opts
                .get("headers")
                .and_then(Value::as_object)
                .and_then(|headers| headers.get("Host"))
                .and_then(string_value)
                .as_deref(),
            Some("cdn.example.com")
        );

        let trojan = &proxies[1];
        assert_eq!(
            trojan.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            trojan.get("sni").and_then(string_value).as_deref(),
            Some("trojan-sni.example.com")
        );
        assert_eq!(
            trojan
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("firefox")
        );
        assert_eq!(
            trojan.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        let trojan_ws_opts = trojan
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("trojan ws opts");
        assert_eq!(
            trojan_ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/trojan")
        );
        assert_eq!(
            trojan_ws_opts
                .get("headers")
                .and_then(Value::as_object)
                .and_then(|headers| headers.get("Host"))
                .and_then(string_value)
                .as_deref(),
            Some("trojan-cdn.example.com")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_anytls_fingerprint_fields() {
        let text = r#"
[
  {
    "protocol": "anytls",
    "name": "Generic AnyTLS",
    "server": "anytls-generic.example.com",
    "port": 8443,
    "username": "user",
    "password": "pass",
    "sni": "sni.example.com",
    "hpkp": "sha256-pin-value",
    "clientFingerprint": "chrome",
    "insecure": true,
    "udp": true
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("anytls")
        );
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("sha256-pin-value")
        );
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_grpc_h2_runtime_fields() {
        let text = r#"
[
  {
    "scheme": "vless",
    "address": "grpc-runtime.example.com",
    "proxyPort": 443,
    "uuid": "00000000-0000-0000-0000-000000000004",
    "tls": true,
    "network": "grpc",
    "serviceName": "free-grpc"
  },
  {
    "protocol": "trojan",
    "server": "h2-runtime.example.com",
    "port": 443,
    "password": "trojan-pass",
    "transport": "http",
    "path": "/h2",
    "host": "h2-cdn.example.com"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        let grpc = &proxies[0];
        assert_eq!(
            grpc.get("network").and_then(string_value).as_deref(),
            Some("grpc")
        );
        let grpc_opts = grpc
            .get("grpc-opts")
            .and_then(Value::as_object)
            .expect("grpc opts");
        assert_eq!(
            grpc_opts
                .get("grpc-service-name")
                .and_then(string_value)
                .as_deref(),
            Some("free-grpc")
        );

        let h2 = &proxies[1];
        assert_eq!(
            h2.get("network").and_then(string_value).as_deref(),
            Some("h2")
        );
        let h2_opts = h2
            .get("h2-opts")
            .and_then(Value::as_object)
            .expect("h2 opts");
        assert_eq!(
            h2_opts
                .get("path")
                .and_then(Value::as_array)
                .and_then(|paths| { paths.first().and_then(string_value) })
                .as_deref(),
            Some("/h2")
        );
        assert_eq!(
            h2_opts
                .get("host")
                .and_then(Value::as_array)
                .and_then(|hosts| { hosts.first().and_then(string_value) })
                .as_deref(),
            Some("h2-cdn.example.com")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_reality_runtime_fields() {
        let text = r#"
[
  {
    "scheme": "vless",
    "address": "generic-reality.example.com",
    "proxyPort": 443,
    "uuid": "00000000-0000-0000-0000-000000000005",
    "security": "reality",
    "sni": "www.cloudflare.com",
    "publicKey": "-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY",
    "shortId": "abcd"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(proxy.get("tls").and_then(Value::as_bool), Some(true));
        let reality_opts = proxy
            .get("reality-opts")
            .and_then(Value::as_object)
            .expect("reality opts");
        assert_eq!(
            reality_opts
                .get("public-key")
                .and_then(string_value)
                .as_deref(),
            Some("-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY")
        );
        assert_eq!(
            reality_opts
                .get("short-id")
                .and_then(string_value)
                .as_deref(),
            Some("abcd")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_hysteria_runtime_fields() {
        let text = r#"
[
  {
    "name": "hy-generic",
    "type": "hysteria",
    "protocol": "udp",
    "server": "hy-generic.example.com",
    "port": 8443,
    "auth": "secret",
    "peer": "sni.example.com",
    "upmbps": 100,
    "downmbps": 200,
    "mport": "8443,9443-9555",
    "hop_interval": 30,
    "obfs": "obfs-pass",
    "obfs_protocol": "wechat-video",
    "alpn": "h3,h4",
    "insecure": true,
    "udp": true
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("hysteria")
        );
        assert_eq!(
            proxy.get("auth_str").and_then(string_value).as_deref(),
            Some("secret")
        );
        assert_eq!(
            proxy.get("protocol").and_then(string_value).as_deref(),
            Some("udp")
        );
        assert_eq!(
            proxy.get("up").and_then(string_value).as_deref(),
            Some("100")
        );
        assert_eq!(
            proxy.get("down").and_then(string_value).as_deref(),
            Some("200")
        );
        assert_eq!(
            proxy.get("ports").and_then(string_value).as_deref(),
            Some("8443,9443-9555")
        );
        assert_eq!(proxy.get("hop-interval").and_then(Value::as_i64), Some(30));
        assert_eq!(
            proxy.get("obfs").and_then(string_value).as_deref(),
            Some("obfs-pass")
        );
        assert_eq!(
            proxy.get("obfs-protocol").and_then(string_value).as_deref(),
            Some("wechat-video")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        let alpn = proxy.get("alpn").and_then(Value::as_array).expect("alpn");
        assert_eq!(alpn.len(), 2);
        assert_eq!(alpn[0].as_str(), Some("h3"));
        assert_eq!(alpn[1].as_str(), Some("h4"));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_hysteria_ports_array() {
        let text = r#"
[
  {
    "name": "hy-array-ports",
    "type": "hysteria",
    "protocol": "udp",
    "server": "hy-array.example.com",
    "port": 443,
    "auth": "secret",
    "mport": [443, "8443-8445"]
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("hysteria")
        );
        assert_eq!(
            proxy.get("ports").and_then(string_value).as_deref(),
            Some("443,8443-8445")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_hysteria2_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "hy2",
    "server": "hy2-generic.example.com",
    "port": 443,
    "password": "hy2-pass",
    "obfs": "salamander",
    "obfsPassword": "obfs-pass",
    "alpn": "h3,h2",
    "udp": true,
    "up_mbps": 100,
    "down_mbps": 200
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("hysteria2")
        );
        assert_eq!(
            proxy.get("obfs").and_then(string_value).as_deref(),
            Some("salamander")
        );
        assert_eq!(
            proxy.get("obfs-password").and_then(string_value).as_deref(),
            Some("obfs-pass")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("up").and_then(string_value).as_deref(),
            Some("100")
        );
        assert_eq!(
            proxy.get("down").and_then(string_value).as_deref(),
            Some("200")
        );
        let alpn = proxy.get("alpn").and_then(Value::as_array).expect("alpn");
        assert_eq!(alpn.len(), 2);
        assert_eq!(alpn[0].as_str(), Some("h3"));
        assert_eq!(alpn[1].as_str(), Some("h2"));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_hysteria2_extended_fields() {
        let text = r#"
[
  {
    "protocol": "hy2",
    "server": "hy2-extended.example.com",
    "port": 443,
    "password": "hy2-pass",
    "pinSHA256": "65b3",
    "upmbps": 114,
    "downmbps": 514,
    "mport": [443, "8443-8445"],
    "hop_interval": 30
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("hysteria2")
        );
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("65b3")
        );
        assert_eq!(
            proxy.get("up").and_then(string_value).as_deref(),
            Some("114")
        );
        assert_eq!(
            proxy.get("down").and_then(string_value).as_deref(),
            Some("514")
        );
        assert_eq!(
            proxy.get("ports").and_then(string_value).as_deref(),
            Some("443,8443-8445")
        );
        assert_eq!(proxy.get("hop-interval").and_then(Value::as_i64), Some(30));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_tuic_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "tuic",
    "server": "tuic-generic.example.com",
    "port": 443,
    "uuid": "00000000-0000-0000-0000-000000000006",
    "password": "tuic-pass",
    "sni": "tuic-sni.example.com",
    "alpn": "h3,h4",
    "udp": true,
    "congestion_control": "bbr",
    "udp_relay_mode": "native",
    "heartbeat_interval": 10000,
    "request_timeout": 8000
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("tuic")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("tuic-sni.example.com")
        );
        assert_eq!(
            proxy
                .get("congestion-controller")
                .and_then(string_value)
                .as_deref(),
            Some("bbr")
        );
        assert_eq!(
            proxy
                .get("udp-relay-mode")
                .and_then(string_value)
                .as_deref(),
            Some("native")
        );
        assert_eq!(
            proxy.get("heartbeat-interval").and_then(Value::as_i64),
            Some(10000)
        );
        assert_eq!(
            proxy.get("request-timeout").and_then(Value::as_i64),
            Some(8000)
        );
        let alpn = proxy.get("alpn").and_then(Value::as_array).expect("alpn");
        assert_eq!(alpn.len(), 2);
        assert_eq!(alpn[0].as_str(), Some("h3"));
        assert_eq!(alpn[1].as_str(), Some("h4"));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_tuic_extended_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "tuic",
    "name": "Generic TUIC Extended",
    "server": "tuic-extended.example.com",
    "port": 8443,
    "token": "token-123",
    "fingerprint": "chrome",
    "udp_relay_mode": "quic",
    "disable_sni": true,
    "reduce_rtt": true,
    "udp_over_stream": true,
    "udp_over_stream_version": 2,
    "max_open_streams": 20,
    "max_udp_relay_packet_size": 1500
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("Generic TUIC Extended")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("tuic")
        );
        assert_eq!(
            proxy.get("token").and_then(string_value).as_deref(),
            Some("token-123")
        );
        assert!(proxy.get("uuid").is_none());
        assert!(proxy.get("password").is_none());
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("chrome")
        );
        assert_eq!(
            proxy
                .get("udp-relay-mode")
                .and_then(string_value)
                .as_deref(),
            Some("quic")
        );
        assert_eq!(
            proxy.get("disable-sni").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(proxy.get("reduce-rtt").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("udp-over-stream").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("udp-over-stream-version").and_then(Value::as_i64),
            Some(2)
        );
        assert_eq!(
            proxy.get("max-open-streams").and_then(Value::as_i64),
            Some(20)
        );
        assert_eq!(
            proxy
                .get("max-udp-relay-packet-size")
                .and_then(Value::as_i64),
            Some(1500)
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_wireguard_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "wireguard",
    "server": "wg-generic.example.com",
    "port": 2480,
    "privateKey": "private-key-value",
    "publicKey": "public-key-value",
    "presharedKey": "psk-value",
    "ip": "172.16.0.2",
    "ipv6": "fd01::1",
    "reserved": "U4An",
    "mtu": 1280,
    "persistent_keepalive": 25,
    "allowedIps": "0.0.0.0/0,::/0",
    "dns": "1.1.1.1,8.8.8.8",
    "udp": true,
    "remote_dns_resolve": true
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("wireguard")
        );
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("private-key-value")
        );
        assert_eq!(
            proxy.get("public-key").and_then(string_value).as_deref(),
            Some("public-key-value")
        );
        assert_eq!(
            proxy
                .get("pre-shared-key")
                .and_then(string_value)
                .as_deref(),
            Some("psk-value")
        );
        assert_eq!(
            proxy.get("ip").and_then(string_value).as_deref(),
            Some("172.16.0.2")
        );
        assert_eq!(
            proxy.get("ipv6").and_then(string_value).as_deref(),
            Some("fd01::1")
        );
        assert_eq!(
            proxy.get("reserved").and_then(string_value).as_deref(),
            Some("U4An")
        );
        assert_eq!(proxy.get("mtu").and_then(Value::as_i64), Some(1280));
        assert_eq!(
            proxy.get("persistent-keepalive").and_then(Value::as_i64),
            Some(25)
        );
        assert_eq!(
            proxy.get("allowed-ips").and_then(string_value).as_deref(),
            None
        );
        assert_eq!(
            proxy
                .get("allowed-ips")
                .and_then(Value::as_array)
                .expect("allowed ips")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["0.0.0.0/0".to_string(), "::/0".to_string()]
        );
        assert_eq!(
            proxy
                .get("dns")
                .and_then(Value::as_array)
                .expect("dns")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["1.1.1.1".to_string(), "8.8.8.8".to_string()]
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("remote-dns-resolve").and_then(Value::as_bool),
            Some(true)
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_protocol_short_aliases() {
        let text = r#"
[
  {
    "protocol": "wg",
    "server": "wg-short.example.com",
    "port": 2480,
    "privateKey": "private-key-value",
    "publicKey": "public-key-value",
    "ip": "172.16.0.2"
  },
  {
    "protocol": "hy",
    "server": "hy-short.example.com",
    "port": 8443,
    "auth": "secret",
    "upmbps": 100,
    "downmbps": 200
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        let wireguard = &proxies[0];
        assert_eq!(
            wireguard.get("type").and_then(string_value).as_deref(),
            Some("wireguard")
        );
        assert_eq!(
            wireguard
                .get("private-key")
                .and_then(string_value)
                .as_deref(),
            Some("private-key-value")
        );
        assert_eq!(
            wireguard
                .get("public-key")
                .and_then(string_value)
                .as_deref(),
            Some("public-key-value")
        );

        let hysteria = &proxies[1];
        assert_eq!(
            hysteria.get("type").and_then(string_value).as_deref(),
            Some("hysteria")
        );
        assert_eq!(
            hysteria.get("auth_str").and_then(string_value).as_deref(),
            Some("secret")
        );
        assert_eq!(
            hysteria.get("up").and_then(string_value).as_deref(),
            Some("100")
        );
        assert_eq!(
            hysteria.get("down").and_then(string_value).as_deref(),
            Some("200")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_masque_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "masque",
    "name": "Generic MASQUE",
    "server": "masque-generic.example.com",
    "port": 443,
    "privateKey": "private-key-value",
    "publicKey": "public-key-value",
    "ip": "172.16.0.2",
    "ipv6": "2606:4700:110:84c0:163a:4914:a0ad:3342",
    "uri": "https://example.com/masque",
    "sni": "example.com",
    "mtu": 1280,
    "udp": true,
    "skip_cert_verify": true,
    "network": "tcp",
    "congestion_controller": "bbr",
    "cwnd": 32,
    "bbrProfile": "standard",
    "remote_dns_resolve": true,
    "dns": "1.1.1.1,8.8.8.8"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("Generic MASQUE")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("masque")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("masque-generic.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("private-key-value")
        );
        assert_eq!(
            proxy.get("public-key").and_then(string_value).as_deref(),
            Some("public-key-value")
        );
        assert_eq!(
            proxy.get("ip").and_then(string_value).as_deref(),
            Some("172.16.0.2")
        );
        assert_eq!(
            proxy.get("ipv6").and_then(string_value).as_deref(),
            Some("2606:4700:110:84c0:163a:4914:a0ad:3342")
        );
        assert_eq!(
            proxy.get("uri").and_then(string_value).as_deref(),
            Some("https://example.com/masque")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("example.com")
        );
        assert_eq!(proxy.get("mtu").and_then(parse_port), Some(1280));
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("tcp")
        );
        assert_eq!(
            proxy
                .get("congestion-controller")
                .and_then(string_value)
                .as_deref(),
            Some("bbr")
        );
        assert_eq!(proxy.get("cwnd").and_then(parse_port), Some(32));
        assert_eq!(
            proxy.get("bbr-profile").and_then(string_value).as_deref(),
            Some("standard")
        );
        assert_eq!(
            proxy.get("remote-dns-resolve").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy
                .get("dns")
                .and_then(Value::as_array)
                .expect("dns")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["1.1.1.1".to_string(), "8.8.8.8".to_string()]
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_trusttunnel_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "trusttunnel",
    "name": "Generic TrustTunnel",
    "server": "tt-generic.example.com",
    "port": 443,
    "username": "user",
    "password": "pass",
    "alpn": "h2,http/1.1",
    "sni": "example.com",
    "clientFingerprint": "chrome",
    "skip_cert_verify": true,
    "fingerprint": "sha256-value",
    "certificate": "cert-value",
    "privateKey": "key-value",
    "udp": true,
    "health_check": true,
    "quic": true,
    "congestion_controller": "bbr",
    "cwnd": 64,
    "bbrProfile": "aggressive",
    "max_connections": 8,
    "min_streams": 5,
    "max_streams": 16
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("Generic TrustTunnel")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("trusttunnel")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("tt-generic.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            proxy
                .get("alpn")
                .and_then(Value::as_array)
                .expect("alpn")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["h2".to_string(), "http/1.1".to_string()]
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("example.com")
        );
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("sha256-value")
        );
        assert_eq!(
            proxy.get("certificate").and_then(string_value).as_deref(),
            Some("cert-value")
        );
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("key-value")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("health-check").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(proxy.get("quic").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy
                .get("congestion-controller")
                .and_then(string_value)
                .as_deref(),
            Some("bbr")
        );
        assert_eq!(proxy.get("cwnd").and_then(parse_port), Some(64));
        assert_eq!(
            proxy.get("bbr-profile").and_then(string_value).as_deref(),
            Some("aggressive")
        );
        assert_eq!(proxy.get("max-connections").and_then(parse_port), Some(8));
        assert_eq!(proxy.get("min-streams").and_then(parse_port), Some(5));
        assert_eq!(proxy.get("max-streams").and_then(parse_port), Some(16));
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_ssh_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "ssh",
    "name": "Generic SSH",
    "server": "ssh-generic.example.com",
    "port": 22,
    "username": "root",
    "password": "password",
    "privateKey": "key-value",
    "privateKeyPassphrase": "passphrase",
    "hostKey": "key-a,key-b",
    "hostKeyAlgorithms": "ssh-ed25519,rsa-sha2-256"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("Generic SSH")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("ssh")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("ssh-generic.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(22));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("root")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("password")
        );
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("key-value")
        );
        assert_eq!(
            proxy
                .get("private-key-passphrase")
                .and_then(string_value)
                .as_deref(),
            Some("passphrase")
        );
        assert_eq!(
            proxy
                .get("host-key")
                .and_then(Value::as_array)
                .expect("host key")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["key-a".to_string(), "key-b".to_string()]
        );
        assert_eq!(
            proxy
                .get("host-key-algorithms")
                .and_then(Value::as_array)
                .expect("host key algorithms")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["ssh-ed25519".to_string(), "rsa-sha2-256".to_string()]
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_snell_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "snell",
    "name": "Generic Snell",
    "server": "snell-generic.example.com",
    "port": 44046,
    "psk": "psk-value",
    "version": 3,
    "obfs": "http",
    "obfsHost": "www.bing.com"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("Generic Snell")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("snell")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("snell-generic.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(44046));
        assert_eq!(
            proxy.get("psk").and_then(string_value).as_deref(),
            Some("psk-value")
        );
        assert_eq!(proxy.get("version").and_then(Value::as_i64), Some(3));
        let obfs_opts = proxy
            .get("obfs-opts")
            .and_then(Value::as_object)
            .expect("snell obfs opts");
        assert_eq!(
            obfs_opts.get("mode").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            obfs_opts.get("host").and_then(string_value).as_deref(),
            Some("www.bing.com")
        );
    }

    #[test]
    fn test_parse_proxies_reads_generic_proxy_list_mieru_runtime_fields() {
        let text = r#"
[
  {
    "protocol": "mieru",
    "name": "Generic Mieru",
    "server": "mieru-generic.example.com",
    "port": 2999,
    "username": "user",
    "password": "pass",
    "transport": "TCP",
    "multiplexing": "MULTIPLEXING_HIGH",
    "handshakeMode": "HANDSHAKE_NO_WAIT",
    "trafficPattern": "CCoQARoECAEQCiIYCAMQASoIMDAwMTAyMDMqCDA0MDUwNjA3"
  }
]
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("Generic Mieru")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("mieru")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("mieru-generic.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(2999));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            proxy.get("transport").and_then(string_value).as_deref(),
            Some("TCP")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("multiplexing").and_then(string_value).as_deref(),
            Some("MULTIPLEXING_HIGH")
        );
        assert_eq!(
            proxy
                .get("handshake-mode")
                .and_then(string_value)
                .as_deref(),
            Some("HANDSHAKE_NO_WAIT")
        );
        assert_eq!(
            proxy
                .get("traffic-pattern")
                .and_then(string_value)
                .as_deref(),
            Some("CCoQARoECAEQCiIYCAMQASoIMDAwMTAyMDMqCDA0MDUwNjA3")
        );
    }

    #[test]
    fn test_parse_proxies_reads_wrapped_generic_proxy_list_json_alias_fields() {
        let text = r#"
{
  "data": [
    {
      "type": "https",
      "address": "wrapped-http.example.com",
      "port": 9001
    },
    {
      "scheme": "socks4",
      "addr": "203.0.113.77",
      "port": 31034
    }
  ]
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-wrapped-http.example.com:9001")
        );
        assert!(!proxies.iter().any(|proxy| {
            proxy.get("server").and_then(string_value).as_deref() == Some("203.0.113.77")
        }));
    }

    #[test]
    fn test_parse_proxies_reads_root_json_list_and_records_proxy_arrays() {
        let text = r#"
{
  "list": [
    {
      "type": "http",
      "address": "root-list.example.com",
      "port": 8080
    }
  ],
  "records": [
    {
      "scheme": "socks5",
      "addr": "198.51.100.44",
      "port": 1080
    }
  ]
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-root-list.example.com:8080")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-198.51.100.44:1080")
        );
    }

    #[test]
    fn test_parse_proxies_reads_result_and_response_proxy_wrappers() {
        let text = r#"
{
  "result": [
    {
      "type": "http",
      "address": "result.example.com",
      "port": 8080
    }
  ],
  "response": {
    "items": [
      {
        "scheme": "socks5",
        "addr": "203.0.113.88",
        "port": 1080
      }
    ]
  }
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-result.example.com:8080")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.88:1080")
        );
    }

    #[test]
    fn test_parse_proxies_reads_nodes_and_servers_proxy_wrappers() {
        let text = r#"
{
  "nodes": [
    {
      "type": "http",
      "address": "nodes.example.com",
      "port": 8080
    }
  ],
  "servers": {
    "items": [
      {
        "scheme": "socks5",
        "addr": "203.0.113.99",
        "port": 1080
      }
    ]
  }
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-nodes.example.com:8080")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.99:1080")
        );
    }

    #[test]
    fn test_parse_proxies_reads_proxy_list_named_wrappers() {
        let text = r#"
{
  "proxyList": [
    {
      "type": "http",
      "address": "proxy-list.example.com",
      "port": 8080
    }
  ],
  "proxy_list": {
    "items": [
      {
        "scheme": "socks5",
        "addr": "198.51.100.99",
        "port": 1080
      }
    ]
  }
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-proxy-list.example.com:8080")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-198.51.100.99:1080")
        );
    }

    #[test]
    fn test_parse_proxies_reads_nested_wrapped_generic_proxy_list_json_arrays() {
        let text = r#"
{
  "data": {
    "list": [
      {
        "type": "http",
        "address": "nested-list.example.com",
        "port": 8088
      }
    ],
    "items": [
      {
        "scheme": "socks5",
        "addr": "192.0.2.44",
        "port": 1080
      }
    ]
  },
  "results": {
    "proxies": [
      {
        "protocol": "https",
        "host": "nested-results.example.com",
        "port": 9001
      }
    ]
  }
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 3);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-nested-list.example.com:8088")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-192.0.2.44:1080")
        );
        assert_eq!(
            proxies[2].get("name").and_then(string_value).as_deref(),
            Some("http-nested-results.example.com:9001")
        );
    }

    #[test]
    fn test_parse_proxies_reads_rows_and_entries_proxy_wrappers() {
        let text = r#"
{
  "rows": [
    {
      "protocol": "http",
      "server": "rows.example.com",
      "port": 8080
    }
  ],
  "entries": [
    {
      "scheme": "socks5",
      "host": "203.0.113.50",
      "port": 1080
    }
  ]
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("http-rows.example.com:8080")
        );
        assert_eq!(
            proxies[1].get("name").and_then(string_value).as_deref(),
            Some("socks5-203.0.113.50:1080")
        );
    }

    #[test]
    fn test_parse_proxies_keeps_named_data_proxy_map_entries() {
        let text = r#"
{
  "proxies": {
    "data": {
      "type": "http",
      "server": "named-data.example.com",
      "port": 8080
    }
  }
}
"#;

        assert!(has_yaml_proxy_collection_hint(text));

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("name").and_then(string_value).as_deref(),
            Some("data")
        );
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("named-data.example.com")
        );
    }

    #[test]
    fn test_generic_proxy_list_object_parses_proxy_uri_lazily() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn generic_proxy_list_object_to_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn first_string_value").next())
            .expect("generic proxy list parser body");

        assert!(
            !body.contains("let parsed_uri = uri.and_then"),
            "generic proxy-list JSON entries should avoid eager Url parsing when protocol/ip/port fields are already present"
        );
        assert!(
            body.contains("parsed_uri.is_none()"),
            "generic proxy-list parser should parse the proxy URI only for missing fields"
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_pipe_separated_nodes_on_one_line() {
        let text = "ss://aes-128-gcm:pass@ss.example.com:443#SS|trojan://secret@trojan.example.com:443#Trojan";

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("ss.example.com")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("trojan.example.com")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_sing_box_outbounds() {
        let text = r#"
{
  "outbounds": [
    {
      "type": "shadowsocks",
      "tag": "SS Out",
      "server": "ss.example.com",
      "server_port": 8388,
      "method": "aes-128-gcm",
      "password": "ss-pass"
    },
    {
      "type": "vless",
      "tag": "VLESS WS",
      "server": "vless.example.com",
      "server_port": 443,
      "uuid": "00000000-0000-0000-0000-000000000000",
      "flow": "xtls-rprx-vision",
      "tls": {
        "enabled": true,
        "server_name": "sni.example.com",
        "insecure": true,
        "utls": { "enabled": true, "fingerprint": "chrome" },
        "reality": { "enabled": true, "public_key": "-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY", "short_id": "abcd" }
      },
      "transport": {
        "type": "ws",
        "path": "/edge",
        "headers": { "Host": "cdn.example.com" }
      }
    },
    {
      "type": "trojan",
      "tag": "Trojan gRPC",
      "server": "trojan.example.com",
      "server_port": 443,
      "password": "trojan-pass",
      "tls": { "enabled": true, "server_name": "trojan-sni.example.com" },
      "transport": { "type": "grpc", "service_name": "grpc-service" }
    },
    {
      "type": "hysteria2",
      "tag": "HY2",
      "server": "hy2.example.com",
      "server_port": 443,
      "password": "hy2-pass",
      "obfs": { "type": "salamander", "password": "obfs-pass" }
    },
    {
      "type": "hysteria",
      "tag": "HY1",
      "server": "hy1.example.com",
      "server_port": 8443,
      "auth_str": "hy1-auth",
      "protocol": "udp",
      "up_mbps": 100,
      "down_mbps": 200,
      "server_ports": "8443,9443-9555",
      "obfs": "obfs-pass",
      "tls": { "enabled": true, "server_name": "hy1-sni.example.com", "insecure": true }
    },
    {
      "type": "tuic",
      "tag": "TUIC",
      "server": "tuic.example.com",
      "server_port": 443,
      "uuid": "uuid-123",
      "password": "tuic-pass",
      "congestion_control": "bbr",
      "udp_relay_mode": "native"
    },
    {
      "type": "anytls",
      "tag": "AnyTLS",
      "server": "anytls.example.com",
      "server_port": 8443,
      "username": "any-user",
      "password": "any-pass",
      "udp": true,
      "tls": { "enabled": true, "server_name": "any-sni.example.com", "insecure": true }
    },
    {
      "type": "wireguard",
      "tag": "WG",
      "server": "wg.example.com",
      "server_port": 2480,
      "private_key": "private-key-value",
      "peer_public_key": "public-key-value",
      "pre_shared_key": "psk-value",
      "local_address": ["172.16.0.2/32", "fd01::2/128"],
      "reserved": "U4An",
      "mtu": 1280,
      "udp": true
    },
    {
      "type": "socks",
      "tag": "SOCKS",
      "server": "socks.example.com",
      "server_port": 1080,
      "username": "socks-user",
      "password": "socks-pass",
      "udp": true
    },
    {
      "type": "http",
      "tag": "HTTP",
      "server": "http.example.com",
      "server_port": 8443,
      "username": "http-user",
      "password": "http-pass",
      "tls": { "enabled": true, "server_name": "http-sni.example.com", "insecure": true }
    },
    {
      "type": "ssh",
      "tag": "SSH",
      "server": "ssh.example.com",
      "server_port": 22,
      "username": "ssh-user",
      "private_key": "ssh-private-key",
      "private_key_passphrase": "ssh-passphrase"
    },
    { "type": "direct", "tag": "direct" }
  ]
}
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 11);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("ss")
        );
        assert_eq!(
            proxies[0].get("cipher").and_then(string_value).as_deref(),
            Some("aes-128-gcm")
        );

        let vless = &proxies[1];
        assert_eq!(
            vless.get("type").and_then(string_value).as_deref(),
            Some("vless")
        );
        assert_eq!(
            vless.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            vless
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        let reality = vless
            .get("reality-opts")
            .and_then(Value::as_object)
            .expect("reality opts");
        assert_eq!(
            reality.get("public-key").and_then(string_value).as_deref(),
            Some("-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY")
        );
        assert_eq!(
            reality.get("short-id").and_then(string_value).as_deref(),
            Some("abcd")
        );
        let ws_opts = vless
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/edge")
        );

        let trojan = &proxies[2];
        assert_eq!(
            trojan.get("network").and_then(string_value).as_deref(),
            Some("grpc")
        );
        let grpc_opts = trojan
            .get("grpc-opts")
            .and_then(Value::as_object)
            .expect("grpc opts");
        assert_eq!(
            grpc_opts
                .get("grpc-service-name")
                .and_then(string_value)
                .as_deref(),
            Some("grpc-service")
        );

        assert_eq!(
            proxies[3].get("obfs").and_then(string_value).as_deref(),
            Some("salamander")
        );

        let hysteria = &proxies[4];
        assert_eq!(
            hysteria.get("type").and_then(string_value).as_deref(),
            Some("hysteria")
        );
        assert_eq!(hysteria.get("port").and_then(parse_port), Some(8443));
        assert_eq!(
            hysteria.get("auth_str").and_then(string_value).as_deref(),
            Some("hy1-auth")
        );
        assert_eq!(
            hysteria.get("protocol").and_then(string_value).as_deref(),
            Some("udp")
        );
        assert_eq!(
            hysteria.get("ports").and_then(string_value).as_deref(),
            Some("8443,9443-9555")
        );
        assert_eq!(
            hysteria.get("sni").and_then(string_value).as_deref(),
            Some("hy1-sni.example.com")
        );
        assert_eq!(
            hysteria.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );

        assert_eq!(
            proxies[5]
                .get("congestion-controller")
                .and_then(string_value)
                .as_deref(),
            Some("bbr")
        );

        let anytls = &proxies[6];
        assert_eq!(
            anytls.get("type").and_then(string_value).as_deref(),
            Some("anytls")
        );
        assert_eq!(
            anytls.get("username").and_then(string_value).as_deref(),
            Some("any-user")
        );
        assert_eq!(
            anytls.get("password").and_then(string_value).as_deref(),
            Some("any-pass")
        );
        assert_eq!(
            anytls.get("sni").and_then(string_value).as_deref(),
            Some("any-sni.example.com")
        );
        assert_eq!(anytls.get("udp").and_then(Value::as_bool), Some(true));

        let wireguard = &proxies[7];
        assert_eq!(
            wireguard.get("type").and_then(string_value).as_deref(),
            Some("wireguard")
        );
        assert_eq!(
            wireguard
                .get("private-key")
                .and_then(string_value)
                .as_deref(),
            Some("private-key-value")
        );
        assert_eq!(
            wireguard
                .get("public-key")
                .and_then(string_value)
                .as_deref(),
            Some("public-key-value")
        );
        assert_eq!(
            wireguard
                .get("pre-shared-key")
                .and_then(string_value)
                .as_deref(),
            Some("psk-value")
        );
        assert_eq!(
            wireguard.get("ip").and_then(string_value).as_deref(),
            Some("172.16.0.2/32")
        );
        assert_eq!(
            wireguard.get("ipv6").and_then(string_value).as_deref(),
            Some("fd01::2/128")
        );
        assert_eq!(wireguard.get("mtu").and_then(parse_port), Some(1280));
        assert_eq!(wireguard.get("udp").and_then(Value::as_bool), Some(true));

        let socks = &proxies[8];
        assert_eq!(
            socks.get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            socks.get("username").and_then(string_value).as_deref(),
            Some("socks-user")
        );
        assert_eq!(socks.get("udp").and_then(Value::as_bool), Some(true));

        let http = &proxies[9];
        assert_eq!(
            http.get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            http.get("username").and_then(string_value).as_deref(),
            Some("http-user")
        );
        assert_eq!(http.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            http.get("sni").and_then(string_value).as_deref(),
            Some("http-sni.example.com")
        );

        let ssh = &proxies[10];
        assert_eq!(
            ssh.get("type").and_then(string_value).as_deref(),
            Some("ssh")
        );
        assert_eq!(
            ssh.get("username").and_then(string_value).as_deref(),
            Some("ssh-user")
        );
        assert_eq!(
            ssh.get("private-key").and_then(string_value).as_deref(),
            Some("ssh-private-key")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_sing_box_outbound_map() {
        let text = r#"
outbounds:
  ss-map:
    type: shadowsocks
    server: ss-map.example.com
    server_port: 8388
    method: aes-128-gcm
    password: ss-pass
  explicit-tag:
    type: trojan
    tag: kept-tag
    server: trojan-map.example.com
    server_port: 443
    password: trojan-pass
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("name").and_then(string_value).as_deref() == Some("ss-map")
                && proxy.get("server").and_then(string_value).as_deref()
                    == Some("ss-map.example.com")
        }));
        assert!(proxies.iter().any(|proxy| {
            proxy.get("name").and_then(string_value).as_deref() == Some("kept-tag")
                && proxy.get("server").and_then(string_value).as_deref()
                    == Some("trojan-map.example.com")
        }));
    }

    #[test]
    fn test_parse_yaml_proxies_reads_sing_box_hysteria2_server_ports_only() {
        let text = r#"
{
  "outbounds": [
    {
      "type": "hysteria2",
      "tag": "HY2 Multi",
      "server": "hy2-multi.example.com",
      "server_ports": "443,8443-8445",
      "password": "hy2-pass",
      "tls": { "enabled": true, "server_name": "hy2.example.com" }
    }
  ]
}
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("hysteria2")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("ports").and_then(string_value).as_deref(),
            Some("443,8443-8445")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_reads_sing_box_hysteria2_server_ports_array() {
        let text = r#"
{
  "outbounds": [
    {
      "type": "hysteria2",
      "tag": "HY2 Array",
      "server": "hy2-array.example.com",
      "server_ports": [443, "8443-8445"],
      "password": "hy2-pass"
    }
  ]
}
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("ports").and_then(string_value).as_deref(),
            Some("443,8443-8445")
        );
    }

    #[test]
    fn test_parse_uri_proxies_skips_oversized_uri_and_keeps_following_proxy() {
        let oversized = format!(
            "vless://uuid@oversized.example.com:443?path={}#Oversized",
            "a".repeat(MAX_FREE_NODE_PROXY_URI_BYTES)
        );
        let text =
            format!("{oversized}\nvless://uuid@good.example.com:443?security=tls&type=ws#Good");

        let proxies = parse_uri_proxies(&text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("good.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxy_rejects_excessive_query_pairs() {
        let query = (0..=MAX_FREE_NODE_PROXY_URI_QUERY_PAIRS)
            .map(|index| format!("k{index}=v"))
            .collect::<Vec<_>>()
            .join("&");
        let value = format!("vless://uuid@example.com:443?{query}#TooManyPairs");

        assert!(proxy_uri_exceeds_complexity_limit(&value));
        assert!(parse_uri_proxy(&value).is_none());
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless() {
        let proxies = parse_proxies("vless://uuid@example.com:443?security=tls&type=ws#Node");

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("type").and_then(string_value).as_deref(),
            Some("vless")
        );
        assert_eq!(proxies[0].get("port").and_then(parse_port), Some(443));
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_packet_encoding() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@default-xudp.example.com:443?security=tls&type=ws#Default%20XUDP\n\
             vless://00000000-0000-0000-0000-000000000001@packet.example.com:443?security=tls&type=ws&packetEncoding=packet#Packet\n\
             vless://00000000-0000-0000-0000-000000000002@none.example.com:443?security=tls&type=ws&packetEncoding=none#None",
        );

        assert_eq!(proxies.len(), 3);
        assert_eq!(proxies[0].get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(proxies[0].get("xudp").and_then(Value::as_bool), Some(true));
        assert!(!proxies[0].contains_key("packet-addr"));

        assert_eq!(proxies[1].get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxies[1].get("packet-addr").and_then(Value::as_bool),
            Some(true)
        );
        assert!(!proxies[1].contains_key("xudp"));

        assert_eq!(proxies[2].get("udp").and_then(Value::as_bool), Some(true));
        assert!(!proxies[2].contains_key("xudp"));
        assert!(!proxies[2].contains_key("packet-addr"));
    }

    #[test]
    fn test_parse_uri_proxies_reads_pcs_fingerprint() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@vless-pcs.example.com:443?security=tls&pcs=vless-pin#VLESS%20PCS\n\
             vmess://00000000-0000-0000-0000-000000000001@vmess-pcs.example.com:443?security=tls&pcs=vmess-pin#VMess%20PCS",
        );

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0]
                .get("fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("vless-pin")
        );
        assert_eq!(
            proxies[1]
                .get("fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("vmess-pin")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_base64_host() {
        let encoded_host = URL_SAFE.encode("base64-host.example.com:443");
        let proxies = parse_proxies(&format!(
            "vless://00000000-0000-0000-0000-000000000000@{encoded_host}?security=tls&type=ws#VLESS%20Base64%20Host"
        ));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("base64-host.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("vless")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_websocket_opts() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@ws.example.com:443?security=tls&type=ws&path=%2Fedge&host=cdn.example.com&sni=sni.example.com#VLESS%20WS",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("servername").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        let ws_opts = proxy
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/edge")
        );
        let headers = ws_opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("ws headers");
        assert_eq!(
            headers.get("Host").and_then(string_value).as_deref(),
            Some("cdn.example.com")
        );
    }

    #[test]
    fn test_normalize_user_info_network_borrows_common_lowercase_type() {
        let params = HashMap::from([("type".to_string(), "ws".to_string())]);
        let normalized = normalize_user_info_network(&params).expect("network");
        assert!(matches!(normalized, Cow::Borrowed("ws")));

        let params = HashMap::from([("type".to_string(), "WS".to_string())]);
        let normalized = normalize_user_info_network(&params).expect("network");
        assert!(matches!(normalized, Cow::Owned(_)));
        assert_eq!(normalized.as_ref(), "ws");

        let params = HashMap::from([("type".to_string(), "HTTP".to_string())]);
        let normalized = normalize_user_info_network(&params).expect("network");
        assert!(matches!(normalized, Cow::Borrowed("h2")));

        let params = HashMap::from([
            ("type".to_string(), "TCP".to_string()),
            ("headerType".to_string(), "HTTP".to_string()),
        ]);
        let normalized = normalize_user_info_network(&params).expect("network");
        assert!(matches!(normalized, Cow::Borrowed("http")));
    }

    #[test]
    fn test_normalize_vmess_network_reuses_common_lowercase_type() {
        let object = Map::new();
        let network = "ws".to_string();
        let pointer = network.as_ptr();
        let normalized = normalize_vmess_network(network, &object);
        assert_eq!(normalized, "ws");
        assert_eq!(normalized.as_ptr(), pointer);

        assert_eq!(normalize_vmess_network("HTTP".to_string(), &object), "h2");

        let object = Map::from_iter([("type".to_string(), json!("http"))]);
        assert_eq!(normalize_vmess_network("tcp".to_string(), &object), "http");
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_tcp_http_header_opts() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@http.example.com:443?security=tls&type=TCP&headerType=HTTP&method=POST&path=%2Fedge&host=cdn.example.com&sni=sni.example.com#VLESS%20HTTP",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("http")
        );
        let http_opts = proxy
            .get("http-opts")
            .and_then(Value::as_object)
            .expect("http opts");
        assert_eq!(
            http_opts.get("method").and_then(string_value).as_deref(),
            Some("POST")
        );
        let paths = http_opts
            .get("path")
            .and_then(Value::as_array)
            .expect("http paths");
        assert_eq!(paths.len(), 1);
        assert_eq!(paths[0].as_str(), Some("/edge"));
        let headers = http_opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("http headers");
        let hosts = headers
            .get("Host")
            .and_then(Value::as_array)
            .expect("http host headers");
        assert_eq!(hosts.len(), 1);
        assert_eq!(hosts[0].as_str(), Some("cdn.example.com"));
        assert!(!proxy.contains_key("h2-opts"));
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_http_transport_as_h2_opts() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@h2.example.com:443?security=tls&type=HTTP&path=%2Fh2&host=h2-cdn.example.com&sni=h2-sni.example.com#VLESS%20H2",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("h2")
        );
        let h2_opts = proxy
            .get("h2-opts")
            .and_then(Value::as_object)
            .expect("h2 opts");
        assert_eq!(
            h2_opts.get("path").and_then(string_value).as_deref(),
            Some("/h2")
        );
        let hosts = h2_opts
            .get("host")
            .and_then(Value::as_array)
            .expect("h2 hosts");
        assert_eq!(hosts.len(), 1);
        assert_eq!(hosts[0].as_str(), Some("h2-cdn.example.com"));
        assert!(!proxy.contains_key("http-opts"));
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_httpupgrade_opts() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@upgrade.example.com:443?security=tls&type=httpupgrade&path=%2Fupgrade&host=upgrade-cdn.example.com&ed=2048&sni=upgrade-sni.example.com#VLESS%20HTTPUpgrade",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("httpupgrade")
        );
        let ws_opts = proxy
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/upgrade")
        );
        assert_eq!(
            ws_opts
                .get("v2ray-http-upgrade-fast-open")
                .and_then(Value::as_bool),
            Some(true)
        );
        let headers = ws_opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("ws headers");
        assert_eq!(
            headers.get("Host").and_then(string_value).as_deref(),
            Some("upgrade-cdn.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_xhttp_opts() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@xhttp.example.com:443?security=tls&type=xhttp&path=%2Fxhttp&host=xhttp-cdn.example.com&mode=stream-one&sni=xhttp-sni.example.com#VLESS%20XHTTP",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("xhttp")
        );
        let xhttp_opts = proxy
            .get("xhttp-opts")
            .and_then(Value::as_object)
            .expect("xhttp opts");
        assert_eq!(
            xhttp_opts.get("path").and_then(string_value).as_deref(),
            Some("/xhttp")
        );
        assert_eq!(
            xhttp_opts.get("host").and_then(string_value).as_deref(),
            Some("xhttp-cdn.example.com")
        );
        assert_eq!(
            xhttp_opts.get("mode").and_then(string_value).as_deref(),
            Some("stream-one")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_alpn() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@alpn.example.com:443?security=tls&type=http&path=%2Falpn&host=alpn-cdn.example.com&sni=alpn-sni.example.com&alpn=h2,http%2F1.1#VLESS%20ALPN",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("h2")
        );
        let alpn = proxy.get("alpn").and_then(Value::as_array).expect("alpn");
        assert_eq!(alpn.len(), 2);
        assert_eq!(alpn[0].as_str(), Some("h2"));
        assert_eq!(alpn[1].as_str(), Some("http/1.1"));
    }

    #[test]
    fn test_parse_uri_proxies_defaults_vless_tls_fingerprint() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@default-fp.example.com:443?security=tls&type=ws&path=%2Fdefault-fp&host=default-fp-cdn.example.com&sni=default-fp-sni.example.com#VLESS%20Default%20FP",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(proxy.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_trojan_websocket_opts() {
        let proxies = parse_proxies(
            "trojan://password@trojan-ws.example.com:443?security=tls&type=ws&path=%2Ftrojan&host=trojan-cdn.example.com&sni=trojan-sni.example.com#Trojan%20WS",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("trojan")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("password")
        );
        let ws_opts = proxy
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/trojan")
        );
        let headers = ws_opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("ws headers");
        assert_eq!(
            headers.get("Host").and_then(string_value).as_deref(),
            Some("trojan-cdn.example.com")
        );
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_grpc_opts() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@grpc.example.com:443?security=tls&type=grpc&serviceName=free-grpc&sni=sni.example.com#VLESS%20gRPC",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("grpc")
        );
        assert_eq!(
            proxy.get("servername").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        let grpc_opts = proxy
            .get("grpc-opts")
            .and_then(Value::as_object)
            .expect("grpc opts");
        assert_eq!(
            grpc_opts
                .get("grpc-service-name")
                .and_then(string_value)
                .as_deref(),
            Some("free-grpc")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_trojan_grpc_opts() {
        let proxies = parse_proxies(
            "trojan://password@trojan-grpc.example.com:443?security=tls&type=grpc&serviceName=trojan-service&sni=trojan-sni.example.com#Trojan%20gRPC",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("trojan")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("password")
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("grpc")
        );
        let grpc_opts = proxy
            .get("grpc-opts")
            .and_then(Value::as_object)
            .expect("grpc opts");
        assert_eq!(
            grpc_opts
                .get("grpc-service-name")
                .and_then(string_value)
                .as_deref(),
            Some("trojan-service")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_websocket_opts() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess WS",
                "add": "vmess-ws.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "ws",
                "type": "none",
                "host": "vmess-cdn.example.com",
                "path": "/vmess",
                "tls": "tls",
                "sni": "vmess-sni.example.com"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("vmess")
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("servername").and_then(string_value).as_deref(),
            Some("vmess-sni.example.com")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(proxy.get("xudp").and_then(Value::as_bool), Some(true));
        let ws_opts = proxy
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/vmess")
        );
        let headers = ws_opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("ws headers");
        assert_eq!(
            headers.get("Host").and_then(string_value).as_deref(),
            Some("vmess-cdn.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_defaults_vmess_websocket_path() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess WS Default Path",
                "add": "vmess-ws-default.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "ws",
                "type": "none",
                "host": "vmess-default-cdn.example.com",
                "tls": "tls",
                "sni": "vmess-default-sni.example.com"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        let ws_opts = proxy
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/")
        );
        let headers = ws_opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("ws headers");
        assert_eq!(
            headers.get("Host").and_then(string_value).as_deref(),
            Some("vmess-default-cdn.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_websocket_early_data_opts() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess WS Early Data",
                "add": "vmess-ws-early.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "ws",
                "type": "none",
                "host": "vmess-early-cdn.example.com",
                "path": "/vmess?ed=2048&eh=X-Edge",
                "tls": "tls",
                "sni": "vmess-early-sni.example.com"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        let ws_opts = proxy
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/vmess?eh=X-Edge")
        );
        assert_eq!(
            ws_opts.get("max-early-data").and_then(Value::as_i64),
            Some(2048)
        );
        assert_eq!(
            ws_opts
                .get("early-data-header-name")
                .and_then(string_value)
                .as_deref(),
            Some("X-Edge")
        );
    }

    #[test]
    fn test_ws_early_data_path_query_preallocates_kept_pairs() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn insert_ws_early_data_opts")
            .nth(1)
            .and_then(|rest| rest.split("fn insert_grpc_opts").next())
            .expect("insert_ws_early_data_opts body");

        assert!(
            body.contains("let mut kept = Vec::with_capacity(query_pair_capacity(query));"),
            "WebSocket early-data query cleanup should preallocate kept pairs from the query pair count"
        );
        assert!(
            !body.contains("let mut kept = Vec::new();"),
            "WebSocket early-data query cleanup should not grow kept pairs from an empty Vec"
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_grpc_opts() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess gRPC",
                "add": "vmess-grpc.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "grpc",
                "type": "gun",
                "host": "",
                "path": "vmess-grpc-service",
                "tls": "tls",
                "sni": "vmess-grpc-sni.example.com"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("vmess")
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("grpc")
        );
        let grpc_opts = proxy
            .get("grpc-opts")
            .and_then(Value::as_object)
            .expect("grpc opts");
        assert_eq!(
            grpc_opts
                .get("grpc-service-name")
                .and_then(string_value)
                .as_deref(),
            Some("vmess-grpc-service")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_h2_opts() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess h2",
                "add": "vmess-h2.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "h2",
                "type": "none",
                "host": "h2-cdn.example.com",
                "path": "/h2",
                "tls": "tls",
                "sni": "h2-sni.example.com"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("vmess")
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("h2")
        );
        let h2_opts = proxy
            .get("h2-opts")
            .and_then(Value::as_object)
            .expect("h2 opts");
        assert_eq!(
            h2_opts.get("path").and_then(string_value).as_deref(),
            Some("/h2")
        );
        let hosts = h2_opts
            .get("host")
            .and_then(Value::as_array)
            .expect("h2 hosts");
        assert_eq!(hosts.len(), 1);
        assert_eq!(hosts[0].as_str(), Some("h2-cdn.example.com"));
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_alpn() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess ALPN",
                "add": "vmess-alpn.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "h2",
                "type": "none",
                "host": "alpn-cdn.example.com",
                "path": "/alpn",
                "tls": "tls",
                "sni": "alpn-sni.example.com",
                "alpn": "h2,http/1.1"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("h2")
        );
        let alpn = proxy.get("alpn").and_then(Value::as_array).expect("alpn");
        assert_eq!(alpn.len(), 2);
        assert_eq!(alpn[0].as_str(), Some("h2"));
        assert_eq!(alpn[1].as_str(), Some("http/1.1"));
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_aead_uri() {
        let proxies = parse_proxies(
            "vmess://00000000-0000-0000-0000-000000000000@vmess-aead.example.com:443?security=tls&type=ws&path=%2Fvmess&host=cdn.example.com&sni=sni.example.com&fp=chrome&alpn=h2,http%2F1.1&encryption=zero&packetEncoding=packet#VMess%20AEAD",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("vmess")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("vmess-aead.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("uuid").and_then(string_value).as_deref(),
            Some("00000000-0000-0000-0000-000000000000")
        );
        assert_eq!(proxy.get("alterId").and_then(parse_port), Some(0));
        assert_eq!(
            proxy.get("cipher").and_then(string_value).as_deref(),
            Some("zero")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("packet-addr").and_then(Value::as_bool),
            Some(true)
        );
        assert!(!proxy.contains_key("xudp"));
        assert_eq!(proxy.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        assert_eq!(
            proxy.get("servername").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        let alpn = proxy.get("alpn").and_then(Value::as_array).expect("alpn");
        assert_eq!(alpn[0].as_str(), Some("h2"));
        assert_eq!(alpn[1].as_str(), Some("http/1.1"));
        let ws_opts = proxy
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/vmess")
        );
        assert_eq!(
            ws_opts
                .get("headers")
                .and_then(Value::as_object)
                .and_then(|headers| headers.get("Host"))
                .and_then(string_value)
                .as_deref(),
            Some("cdn.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_tls_case_insensitive() {
        for tls in ["TLS", "xtls"] {
            let payload = STANDARD.encode(
                json!({
                    "v": "2",
                    "ps": "VMess TLS Case",
                    "add": "vmess-tls-case.example.com",
                    "port": "443",
                    "id": "00000000-0000-0000-0000-000000000000",
                    "aid": "0",
                    "scy": "auto",
                    "net": "ws",
                    "type": "none",
                    "host": "tls-case-cdn.example.com",
                    "path": "/tls-case",
                    "tls": tls,
                    "sni": "tls-case-sni.example.com"
                })
                .to_string(),
            );
            let proxies = parse_proxies(&format!("vmess://{payload}"));

            assert_eq!(proxies.len(), 1);
            let proxy = &proxies[0];
            assert_eq!(proxy.get("tls").and_then(Value::as_bool), Some(true));
        }
    }

    #[test]
    fn test_parse_uri_proxies_reads_vmess_tls_extra_fields() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess TLS Extra",
                "add": "vmess-tls-extra.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "ws",
                "type": "none",
                "host": "tls-extra-cdn.example.com",
                "path": "/tls-extra",
                "tls": "tls",
                "sni": "tls-extra-sni.example.com",
                "fp": "chrome",
                "allowInsecure": "1"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(proxy.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
    }

    #[test]
    fn test_parse_uri_proxies_maps_vmess_http_to_h2_opts() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess http remapped",
                "add": "vmess-http.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "http",
                "type": "none",
                "host": "http-cdn.example.com",
                "path": "/http-h2",
                "tls": "tls"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("h2")
        );
        let h2_opts = proxy
            .get("h2-opts")
            .and_then(Value::as_object)
            .expect("h2 opts");
        assert_eq!(
            h2_opts.get("path").and_then(string_value).as_deref(),
            Some("/http-h2")
        );
        let hosts = h2_opts
            .get("host")
            .and_then(Value::as_array)
            .expect("h2 hosts");
        assert_eq!(hosts[0].as_str(), Some("http-cdn.example.com"));
    }

    #[test]
    fn test_parse_uri_proxies_maps_vmess_type_http_to_http_opts() {
        let payload = STANDARD.encode(
            json!({
                "v": "2",
                "ps": "VMess tcp http",
                "add": "vmess-tcp-http.example.com",
                "port": "443",
                "id": "00000000-0000-0000-0000-000000000000",
                "aid": "0",
                "scy": "auto",
                "net": "tcp",
                "type": "http",
                "host": "tcp-http-cdn.example.com",
                "path": "/tcp-http",
                "tls": "tls"
            })
            .to_string(),
        );
        let proxies = parse_proxies(&format!("vmess://{payload}"));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("http")
        );
        let http_opts = proxy
            .get("http-opts")
            .and_then(Value::as_object)
            .expect("http opts");
        let paths = http_opts
            .get("path")
            .and_then(Value::as_array)
            .expect("http paths");
        assert_eq!(paths[0].as_str(), Some("/tcp-http"));
        let headers = http_opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("http headers");
        let host = headers
            .get("Host")
            .and_then(Value::as_array)
            .expect("http host");
        assert_eq!(host[0].as_str(), Some("tcp-http-cdn.example.com"));
        assert!(!proxy.contains_key("h2-opts"));
    }

    #[test]
    fn test_parse_uri_proxies_reads_vless_reality() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@reality.example.com:443?security=reality&type=tcp&flow=xtls-rprx-vision&sni=www.cloudflare.com&fp=chrome&pbk=-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY&sid=abcd#Reality%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("vless")
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("tcp")
        );
        assert_eq!(proxy.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("flow").and_then(string_value).as_deref(),
            Some("xtls-rprx-vision")
        );
        assert_eq!(
            proxy.get("servername").and_then(string_value).as_deref(),
            Some("www.cloudflare.com")
        );
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        let reality_opts = proxy
            .get("reality-opts")
            .and_then(Value::as_object)
            .expect("reality opts");
        assert_eq!(
            reality_opts
                .get("public-key")
                .and_then(string_value)
                .as_deref(),
            Some("-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY")
        );
        assert_eq!(
            reality_opts
                .get("short-id")
                .and_then(string_value)
                .as_deref(),
            Some("abcd")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_user_info_insecure_aliases() {
        for url in [
            "vless://00000000-0000-0000-0000-000000000000@alias-allow-underscore.example.com:443?security=tls&type=ws&allow_insecure=1#VLESS%20Allow%20Underscore",
            "trojan://secret@alias-skip-dash.example.com:443?skip-cert-verify=true#Trojan%20Skip%20Dash",
            "vmess://00000000-0000-0000-0000-000000000000@alias-skip-camel.example.com:443?security=tls&type=ws&skipCertVerify=true#VMess%20Skip%20Camel",
        ] {
            let proxies = parse_proxies(url);
            assert_eq!(proxies.len(), 1, "url: {url}");
            assert_eq!(
                proxies[0].get("skip-cert-verify").and_then(Value::as_bool),
                Some(true),
                "url: {url}"
            );
        }
    }

    #[test]
    fn test_parse_uri_proxies_drops_invalid_reality_short_id() {
        let proxies = parse_proxies(
            "vless://00000000-0000-0000-0000-000000000000@reality.example.com:443?security=reality&type=tcp&sni=www.cloudflare.com&pbk=-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY&sid=Infinity#Reality%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let reality_opts = proxies[0]
            .get("reality-opts")
            .and_then(Value::as_object)
            .expect("reality opts");
        assert_eq!(
            reality_opts
                .get("public-key")
                .and_then(string_value)
                .as_deref(),
            Some("-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY")
        );
        assert!(!reality_opts.contains_key("short-id"));
    }

    #[test]
    fn test_parse_yaml_proxies_drops_invalid_reality_short_id() {
        let proxies = parse_yaml_proxies(
            r#"
proxies:
  - name: bad-short-id
    type: vless
    server: reality.example.com
    port: 443
    uuid: 00000000-0000-0000-0000-000000000000
    tls: true
    reality-opts:
      public-key: -FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY
      short-id: Infinity
"#,
        );

        assert_eq!(proxies.len(), 1);
        let reality_opts = proxies[0]
            .get("reality-opts")
            .and_then(Value::as_object)
            .expect("reality opts");
        assert_eq!(
            reality_opts
                .get("public-key")
                .and_then(string_value)
                .as_deref(),
            Some("-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY")
        );
        assert!(!reality_opts.contains_key("short-id"));
    }

    #[test]
    fn test_parse_yaml_proxies_decodes_percent_encoded_reality_public_key() {
        let proxies = parse_yaml_proxies(
            r#"
proxies:
  - name: encoded-public-key
    type: vless
    server: reality.example.com
    port: 443
    uuid: 00000000-0000-0000-0000-000000000000
    tls: true
    reality-opts:
      public-key: "%2DFQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY"
      short-id: abcd
"#,
        );

        assert_eq!(proxies.len(), 1);
        let reality_opts = proxies[0]
            .get("reality-opts")
            .and_then(Value::as_object)
            .expect("reality opts");
        assert_eq!(
            reality_opts
                .get("public-key")
                .and_then(string_value)
                .as_deref(),
            Some("-FQM2tUbpiBjwjgla2mwkSkFhFIKQU0FQOvRi0ZD_mY")
        );
        assert_eq!(
            reality_opts
                .get("short-id")
                .and_then(string_value)
                .as_deref(),
            Some("abcd")
        );
    }

    #[test]
    fn test_parse_yaml_proxies_removes_invalid_reality_public_key() {
        let proxies = parse_yaml_proxies(
            r#"
proxies:
  - name: invalid-public-key
    type: vless
    server: reality.example.com
    port: 443
    uuid: 00000000-0000-0000-0000-000000000000
    tls: true
    reality-opts:
      public-key: not-a-public-key
      short-id: abcd
"#,
        );

        assert_eq!(proxies.len(), 1);
        assert!(!proxies[0].contains_key("reality-opts"));
    }

    #[test]
    fn test_parse_uri_proxies_reads_ss_sip002_obfs_plugin() {
        let proxies = parse_proxies(
            "ss://aes-128-gcm:secret@ss.example.com:8388?plugin=obfs-local%3Bobfs%3Dhttp%3Bobfs-host%3Dcdn.example.com#SS%20Obfs",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("ss")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("ss.example.com")
        );
        assert_eq!(
            proxy.get("plugin").and_then(string_value).as_deref(),
            Some("obfs")
        );
        let opts = proxy
            .get("plugin-opts")
            .and_then(Value::as_object)
            .expect("plugin opts");
        assert_eq!(
            opts.get("mode").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            opts.get("host").and_then(string_value).as_deref(),
            Some("cdn.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_keeps_ss_base64_plugin_query() {
        let payload = STANDARD.encode("aes-128-gcm:secret@ss-b64.example.com:8388");
        let proxies = parse_proxies(&format!(
            "ss://{payload}?plugin=obfs-local%3Bobfs%3Dtls%3Bobfs-host%3Dcdn-b64.example.com#SS%20B64%20Obfs"
        ));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("ss-b64.example.com")
        );
        assert_eq!(
            proxy.get("plugin").and_then(string_value).as_deref(),
            Some("obfs")
        );
        let opts = proxy
            .get("plugin-opts")
            .and_then(Value::as_object)
            .expect("plugin opts");
        assert_eq!(
            opts.get("mode").and_then(string_value).as_deref(),
            Some("tls")
        );
        assert_eq!(
            opts.get("host").and_then(string_value).as_deref(),
            Some("cdn-b64.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_rejects_empty_ss_payload_without_recursion() {
        assert!(parse_proxies("ss://").is_empty());
        assert!(parse_proxies("ss://#empty").is_empty());
    }

    #[test]
    fn test_parse_uri_proxies_bounds_ss_payload_decode_to_one_pass() {
        let payload = STANDARD.encode("not-an-ss-authority");
        assert!(parse_proxies(&format!("ss://{payload}")).is_empty());
    }

    #[test]
    fn test_parse_ss_base64_proxy_rebuilds_uri_without_format_chain() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_ss_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_ss_credentials").next())
            .expect("parse_ss_proxy body");
        let query_format = concat!("format!(\"?", "{value}\")");
        let uri_format = concat!("format!(\"ss://", "{decoded}", "{query}#", "{fragment}\")");

        assert!(!body.contains(query_format));
        assert!(!body.contains(uri_format));
    }

    #[test]
    fn test_parse_uri_proxies_reads_ss_v2ray_plugin() {
        let proxies = parse_proxies(
            "ss://aes-128-gcm:secret@ss-v2ray.example.com:8388?plugin=v2ray-plugin%3Bmode%3Dwebsocket%3Bhost%3Dcdn.example.com%3Bpath%3D%2Fws%3Btls#SS%20V2Ray%20Plugin",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("plugin").and_then(string_value).as_deref(),
            Some("v2ray-plugin")
        );
        let opts = proxy
            .get("plugin-opts")
            .and_then(Value::as_object)
            .expect("plugin opts");
        assert_eq!(
            opts.get("mode").and_then(string_value).as_deref(),
            Some("websocket")
        );
        assert_eq!(
            opts.get("host").and_then(string_value).as_deref(),
            Some("cdn.example.com")
        );
        assert_eq!(
            opts.get("path").and_then(string_value).as_deref(),
            Some("/ws")
        );
        assert_eq!(opts.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("SS V2Ray Plugin")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_ss_shadow_tls_plugin() {
        let proxies = parse_proxies(
            "ss://chacha20-ietf-poly1305:secret@ss-shadowtls.example.com:443?plugin=shadow-tls%3Bhost%3Dcloud.tencent.com%3Bpassword%3Dshadow-pass%3Bversion%3D2%3Bclient-fingerprint%3Dchrome%3Balpn%3Dh2%2Chttp%2F1.1%3Bskip-cert-verify%3D1#SS%20ShadowTLS",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("plugin").and_then(string_value).as_deref(),
            Some("shadow-tls")
        );
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        let opts = proxy
            .get("plugin-opts")
            .and_then(Value::as_object)
            .expect("shadow-tls opts");
        assert_eq!(
            opts.get("host").and_then(string_value).as_deref(),
            Some("cloud.tencent.com")
        );
        assert_eq!(
            opts.get("password").and_then(string_value).as_deref(),
            Some("shadow-pass")
        );
        assert_eq!(opts.get("version").and_then(Value::as_i64), Some(2));
        let alpn = opts
            .get("alpn")
            .and_then(Value::as_array)
            .expect("shadow-tls alpn");
        assert_eq!(alpn.len(), 2);
        assert_eq!(alpn[0].as_str(), Some("h2"));
        assert_eq!(alpn[1].as_str(), Some("http/1.1"));
        assert_eq!(
            opts.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
    }

    #[test]
    fn test_ss_shadow_tls_plugin_alpn_avoids_intermediate_vec_collect() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn insert_ss_shadow_tls_plugin_opts")
            .nth(1)
            .and_then(|rest| rest.split("fn insert_ss_gost_plugin_opts").next())
            .unwrap();
        let collect_vec = concat!(".collect::<", "Vec<_>>()");

        assert!(
            !body.contains(collect_vec),
            "shadow-tls alpn parsing should reuse CSV array construction without collecting an intermediate Vec<&str>"
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_ss_gost_plugin() {
        let proxies = parse_proxies(
            "ss://chacha20-ietf-poly1305:secret@ss-gost.example.com:443?plugin=gost-plugin%3Bmode%3Dwebsocket%3Bhost%3Dgost.example.com%3Bpath%3D%2Fgost%3Btls%3Bmux%3D1%3Bfingerprint%3Dsha256-value%3Bskip-cert-verify%3Dtrue%3Bheaders%3DX-Test%3Aedge%7CUser-Agent%3Agost-agent%3Bheader-X-Trace%3Dtrace-1#SS%20Gost",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("plugin").and_then(string_value).as_deref(),
            Some("gost-plugin")
        );
        let opts = proxy
            .get("plugin-opts")
            .and_then(Value::as_object)
            .expect("gost opts");
        assert_eq!(
            opts.get("mode").and_then(string_value).as_deref(),
            Some("websocket")
        );
        assert_eq!(
            opts.get("host").and_then(string_value).as_deref(),
            Some("gost.example.com")
        );
        assert_eq!(
            opts.get("path").and_then(string_value).as_deref(),
            Some("/gost")
        );
        assert_eq!(opts.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(opts.get("mux").and_then(Value::as_bool), Some(true));
        assert_eq!(
            opts.get("fingerprint").and_then(string_value).as_deref(),
            Some("sha256-value")
        );
        assert_eq!(
            opts.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        let headers = opts
            .get("headers")
            .and_then(Value::as_object)
            .expect("gost headers");
        assert_eq!(
            headers.get("X-Test").and_then(string_value).as_deref(),
            Some("edge")
        );
        assert_eq!(
            headers.get("User-Agent").and_then(string_value).as_deref(),
            Some("gost-agent")
        );
        assert_eq!(
            headers.get("X-Trace").and_then(string_value).as_deref(),
            Some("trace-1")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_ss_base64_userinfo() {
        let userinfo = STANDARD.encode("aes-128-gcm:secret");
        let proxies = parse_proxies(&format!(
            "ss://{userinfo}@ss-userinfo.example.com:8388#SS%20UserInfo"
        ));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("ss-userinfo.example.com")
        );
        assert_eq!(
            proxy.get("cipher").and_then(string_value).as_deref(),
            Some("aes-128-gcm")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("secret")
        );
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("SS UserInfo")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_ss_udp_flags() {
        let proxies = parse_proxies(
            "ss://aes-128-gcm:secret@ss-udp.example.com:8388#SS%20UDP\n\
             ss://aes-128-gcm:secret@ss-uot.example.com:8388?uot=1#SS%20UOT\n\
             ss://aes-128-gcm:secret@ss-udp-over-tcp.example.com:8388?udp-over-tcp=true#SS%20UDP%20Over%20TCP",
        );

        assert_eq!(proxies.len(), 3);
        assert_eq!(proxies[0].get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxies[0].get("udp-over-tcp").and_then(Value::as_bool),
            None
        );
        assert_eq!(proxies[1].get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxies[1].get("udp-over-tcp").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(proxies[2].get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxies[2].get("udp-over-tcp").and_then(Value::as_bool),
            Some(true)
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_wireguard() {
        let proxies = parse_proxies(
            "wireguard://private-key-value@wg.example.com:2480?public-key=public-key-value&pre-shared-key=psk-value&ip=172.16.0.2&ipv6=fd01%3A5ca1%3Aab1e%3A80fa%3Aab85%3A6eea%3A213f%3Af4a5&udp=true&reserved=U4An&mtu=1280&persistent-keepalive=25&allowed-ips=0.0.0.0%2F0%2C%3A%3A%2F0&dns=1.1.1.1%2C8.8.8.8&remote-dns-resolve=true#WG%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("wireguard")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("wg.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(2480));
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("private-key-value")
        );
        assert_eq!(
            proxy.get("public-key").and_then(string_value).as_deref(),
            Some("public-key-value")
        );
        assert_eq!(
            proxy
                .get("pre-shared-key")
                .and_then(string_value)
                .as_deref(),
            Some("psk-value")
        );
        assert_eq!(
            proxy.get("ip").and_then(string_value).as_deref(),
            Some("172.16.0.2")
        );
        assert_eq!(
            proxy.get("ipv6").and_then(string_value).as_deref(),
            Some("fd01:5ca1:ab1e:80fa:ab85:6eea:213f:f4a5")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("reserved").and_then(string_value).as_deref(),
            Some("U4An")
        );
        assert_eq!(proxy.get("mtu").and_then(parse_port), Some(1280));
        assert_eq!(
            proxy.get("persistent-keepalive").and_then(parse_port),
            Some(25)
        );
        assert_eq!(
            proxy
                .get("allowed-ips")
                .and_then(Value::as_array)
                .expect("allowed ips")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["0.0.0.0/0".to_string(), "::/0".to_string()]
        );
        assert_eq!(
            proxy
                .get("dns")
                .and_then(Value::as_array)
                .expect("dns")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["1.1.1.1".to_string(), "8.8.8.8".to_string()]
        );
        assert_eq!(
            proxy.get("remote-dns-resolve").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("WG Node")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_wg_alias() {
        let proxies = parse_proxies(
            "wg://private-key-value@wg-alias.example.com:2480?public-key=public-key-value&ip=172.16.0.2&udp=true#WG%20Alias",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("wireguard")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("wg-alias.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(2480));
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("private-key-value")
        );
        assert_eq!(
            proxy.get("public-key").and_then(string_value).as_deref(),
            Some("public-key-value")
        );
        assert_eq!(
            proxy.get("ip").and_then(string_value).as_deref(),
            Some("172.16.0.2")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("WG Alias")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_masque() {
        let proxies = parse_proxies(
            "masque://masque.example.com:443?private-key=private-key-value&public-key=public-key-value&ip=172.16.0.2&ipv6=2606%3A4700%3A110%3A84c0%3A163a%3A4914%3Aa0ad%3A3342&uri=https%3A%2F%2Fexample.com%2Fmasque&sni=example.com&mtu=1280&udp=true&skip-cert-verify=true&network=tcp&congestion-controller=bbr&cwnd=32&bbr-profile=standard&remote-dns-resolve=true&dns=1.1.1.1%2C8.8.8.8#MASQUE%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("MASQUE Node")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("masque")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("masque.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("private-key-value")
        );
        assert_eq!(
            proxy.get("public-key").and_then(string_value).as_deref(),
            Some("public-key-value")
        );
        assert_eq!(
            proxy.get("ip").and_then(string_value).as_deref(),
            Some("172.16.0.2")
        );
        assert_eq!(
            proxy.get("ipv6").and_then(string_value).as_deref(),
            Some("2606:4700:110:84c0:163a:4914:a0ad:3342")
        );
        assert_eq!(
            proxy.get("uri").and_then(string_value).as_deref(),
            Some("https://example.com/masque")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("example.com")
        );
        assert_eq!(proxy.get("mtu").and_then(parse_port), Some(1280));
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("tcp")
        );
        assert_eq!(
            proxy
                .get("congestion-controller")
                .and_then(string_value)
                .as_deref(),
            Some("bbr")
        );
        assert_eq!(proxy.get("cwnd").and_then(parse_port), Some(32));
        assert_eq!(
            proxy.get("bbr-profile").and_then(string_value).as_deref(),
            Some("standard")
        );
        assert_eq!(
            proxy.get("remote-dns-resolve").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy
                .get("dns")
                .and_then(Value::as_array)
                .expect("dns")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["1.1.1.1".to_string(), "8.8.8.8".to_string()]
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_trusttunnel() {
        let proxies = parse_proxies(
            "trusttunnel://user:pass@tt.example.com:443?alpn=h2%2Chttp%2F1.1&sni=example.com&client-fingerprint=chrome&skip-cert-verify=true&fingerprint=sha256-value&certificate=cert-value&private-key=key-value&udp=true&health-check=true&quic=true&congestion-controller=bbr&cwnd=64&bbr-profile=aggressive&max-connections=8&min-streams=5&max-streams=16#TrustTunnel%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("TrustTunnel Node")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("trusttunnel")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("tt.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            proxy
                .get("alpn")
                .and_then(Value::as_array)
                .expect("alpn")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["h2".to_string(), "http/1.1".to_string()]
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("example.com")
        );
        assert_eq!(
            proxy
                .get("client-fingerprint")
                .and_then(string_value)
                .as_deref(),
            Some("chrome")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("sha256-value")
        );
        assert_eq!(
            proxy.get("certificate").and_then(string_value).as_deref(),
            Some("cert-value")
        );
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("key-value")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("health-check").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(proxy.get("quic").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy
                .get("congestion-controller")
                .and_then(string_value)
                .as_deref(),
            Some("bbr")
        );
        assert_eq!(proxy.get("cwnd").and_then(parse_port), Some(64));
        assert_eq!(
            proxy.get("bbr-profile").and_then(string_value).as_deref(),
            Some("aggressive")
        );
        assert_eq!(proxy.get("max-connections").and_then(parse_port), Some(8));
        assert_eq!(proxy.get("min-streams").and_then(parse_port), Some(5));
        assert_eq!(proxy.get("max-streams").and_then(parse_port), Some(16));
    }

    #[test]
    fn test_parse_uri_proxies_reads_ssh() {
        let proxies = parse_proxies(
            "ssh://root:password@ssh.example.com:22?private-key=key-value&private-key-passphrase=passphrase&host-key=key-a%2Ckey-b&host-key-algorithms=ssh-ed25519%2Crsa-sha2-256#SSH%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("SSH Node")
        );
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("ssh")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("ssh.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(22));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("root")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("password")
        );
        assert_eq!(
            proxy.get("private-key").and_then(string_value).as_deref(),
            Some("key-value")
        );
        assert_eq!(
            proxy
                .get("private-key-passphrase")
                .and_then(string_value)
                .as_deref(),
            Some("passphrase")
        );
        assert_eq!(
            proxy
                .get("host-key")
                .and_then(Value::as_array)
                .expect("host key")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["key-a".to_string(), "key-b".to_string()]
        );
        assert_eq!(
            proxy
                .get("host-key-algorithms")
                .and_then(Value::as_array)
                .expect("host key algorithms")
                .iter()
                .filter_map(string_value)
                .collect::<Vec<_>>(),
            vec!["ssh-ed25519".to_string(), "rsa-sha2-256".to_string()]
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_socks5() {
        let proxies = parse_proxies("socks5://user:pass@socks.example.com:1080?udp=1#SOCKS%20Node");

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("socks.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(1080));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("SOCKS Node")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_socks_base64_userinfo() {
        let encoded = STANDARD.encode("user:pass");
        let proxies = parse_proxies(&format!(
            "socks5://{encoded}@socks.example.com:1080#SOCKS%20Base64"
        ));

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_socks_alias() {
        let proxies = parse_proxies("socks://socks.example.net:1080#SOCKS%20Alias");

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("socks.example.net")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(1080));
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("SOCKS Alias")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_socks5h() {
        let proxies =
            parse_proxies("socks5h://user:pass@socks5h.example.com:1080?udp=1#SOCKS5H%20Node");

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("socks5")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("socks5h.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(1080));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("SOCKS5H Node")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_http_proxy_uri() {
        let proxies = parse_proxies(
            "http://user:pass@http-proxy.example.com:8080#HTTP%20Proxy\n\
             https://secure:secret@https-proxy.example.com:8443#HTTPS%20Proxy",
        );

        assert_eq!(proxies.len(), 2);
        let http = &proxies[0];
        assert_eq!(
            http.get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            http.get("server").and_then(string_value).as_deref(),
            Some("http-proxy.example.com")
        );
        assert_eq!(http.get("port").and_then(parse_port), Some(8080));
        assert_eq!(
            http.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            http.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            http.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            http.get("name").and_then(string_value).as_deref(),
            Some("HTTP Proxy")
        );

        let https = &proxies[1];
        assert_eq!(
            https.get("type").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            https.get("server").and_then(string_value).as_deref(),
            Some("https-proxy.example.com")
        );
        assert_eq!(https.get("port").and_then(parse_port), Some(8443));
        assert_eq!(https.get("tls").and_then(Value::as_bool), Some(true));
        assert_eq!(
            https.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            https.get("name").and_then(string_value).as_deref(),
            Some("HTTPS Proxy")
        );
    }

    #[test]
    fn test_parse_uri_proxies_skips_web_urls_with_paths() {
        let proxies = parse_proxies(
            r#"<a href="https://example.com:8443/free-node/list.html?target=clash">free</a>"#,
        );

        assert!(proxies.is_empty());
    }

    #[test]
    fn test_parse_uri_proxies_reads_inline_proxy_uris() {
        let text = r#"
<script>
const nodes = ["trojan://pass@example.com:443?sni=sni.example.com#Trojan%20Inline",
{"link":"vless://00000000-0000-0000-0000-000000000000@example.net:8443?security=tls&type=ws#VLESS%20Inline"},
"trojan://pass@example.com:443?sni=sni.example.com#Trojan%20Inline"];
</script>
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert!(proxies.iter().any(|proxy| {
            proxy.get("type").and_then(string_value).as_deref() == Some("trojan")
        }));
        assert!(proxies
            .iter()
            .any(|proxy| { proxy.get("type").and_then(string_value).as_deref() == Some("vless") }));
    }

    #[test]
    fn test_parse_uri_proxies_skips_non_ascii_prefix_before_scheme_start_filter() {
        let text = "今日节点 ss://aes-128-gcm:pass@unicode-prefix.example.com:443#Unicode";

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("unicode-prefix.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_streams_escaped_values_without_intermediate_list() {
        let text = r#"
ss://aes-128-gcm:pass@example.com:443#One
ss://aes-128-gcm:pass@example.com:443#One
trojan:\/\/pass@trojan.example.com:443?type=ws&path=%2Fws&host=cdn.example.com#Trojan
"#;

        let proxies = parse_uri_proxies(text);

        assert_eq!(proxies.len(), 2);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("example.com")
        );
        assert_eq!(
            proxies[1].get("server").and_then(string_value).as_deref(),
            Some("trojan.example.com")
        );
        let ws_opts = proxies[1]
            .get("ws-opts")
            .and_then(Value::as_object)
            .expect("trojan ws opts");
        assert_eq!(
            ws_opts.get("path").and_then(string_value).as_deref(),
            Some("/ws")
        );
    }

    #[test]
    fn test_uri_dedup_set_uses_hashset_insert_semantics() {
        let mut seen = UriDedupSet::default();
        let mut values = Vec::<String>::new();
        let uri = "ss://aes-128-gcm:pass@example.com:443#One";

        assert!(seen.insert(&values, uri));
        values.push(uri.to_string());
        assert!(!seen.insert(&values, uri));
        assert_eq!(values.len(), 1);
    }

    #[test]
    fn test_parse_uri_proxies_deduplicates_with_single_index_insert() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_uri_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_uri_proxy").next())
            .expect("parse_uri_proxies body");

        assert!(
            !body.contains("seen.contains(value.as_str())"),
            "URI parsing should not hash each URI once for contains and again for insert"
        );
        assert!(
            body.contains("if !seen.insert(&seen_values, &value)"),
            "URI parsing should use UriDedupSet::insert as the single deduplication lookup"
        );
    }

    #[test]
    fn test_parse_uri_proxies_deduplicates_without_cloning_uri_values() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_uri_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_uri_proxy").next())
            .expect("parse_uri_proxies body");

        assert!(
            body.contains("let mut seen_values = Vec::<String>::new();"),
            "URI parsing should keep unique URI values in a side buffer for collision-safe deduplication"
        );
        assert!(
            body.contains("if !seen.insert(&seen_values, &value)"),
            "URI parsing should deduplicate by indexing into the side buffer instead of cloning the URI into a HashSet"
        );
        assert!(
            body.contains("seen_values.push(value);"),
            "URI parsing should move each unique URI into the side buffer after parsing"
        );
        assert!(
            !body.contains("value.clone()"),
            "URI parsing should not clone every unique URI just to deduplicate"
        );
    }

    #[test]
    fn test_parse_uri_proxies_lazily_initializes_output_vec() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_uri_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_uri_proxy").next())
            .expect("parse_uri_proxies body");

        assert!(
            body.contains("let mut proxies = Option::<Vec<Map<String, Value>>>::None;"),
            "parse_uri_proxies should not allocate its output Vec before the first parsed URI"
        );
        assert!(
            body.contains("append_uri_proxies(") && body.contains("&mut proxies,"),
            "parse_uri_proxies should append multi-node Mieru URI results through lazy output initialization"
        );
        assert!(
            body.contains("push_uri_proxy(&mut proxies, proxy);"),
            "parse_uri_proxies should push single URI results through lazy output initialization"
        );
        assert!(
            !body.contains("let mut proxies = Vec::new();"),
            "parse_uri_proxies should avoid eager empty Vec allocation"
        );

        let helper = source
            .split("fn push_uri_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_uri_proxy").next())
            .expect("push_uri_proxy helper");
        assert!(
            helper.contains("Vec::with_capacity(1)"),
            "the first parsed URI should allocate exactly enough initial output capacity"
        );
    }

    #[test]
    fn test_parse_uri_proxies_reuses_text_bytes_in_scan_loop() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_uri_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_uri_proxy").next())
            .expect("parse_uri_proxies body");

        assert!(
            body.contains("let text_bytes = text.as_bytes();"),
            "URI scanning should cache text.as_bytes() once before the hot loop"
        );
        assert!(
            body.contains("text_bytes[cursor]"),
            "URI scanning should use the cached byte slice for cursor checks"
        );
        assert!(
            !body.contains("text.as_bytes()[cursor]"),
            "URI scanning should not repeatedly call text.as_bytes() in the hot loop"
        );
    }

    #[test]
    fn test_parse_uri_proxy_dispatches_by_first_scheme_byte() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_uri_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn proxy_uri_needle_at").next())
            .expect("parse_uri_proxy body");

        assert!(
            body.contains("let first = value.as_bytes().first()?.to_ascii_lowercase();"),
            "parse_uri_proxy should inspect the scheme's first byte once before dispatch"
        );
        for arm in ["b'a'", "b'h'", "b'm'", "b's'", "b't'", "b'v'", "b'w'"] {
            assert!(
                body.contains(arm),
                "parse_uri_proxy should keep a grouped dispatch arm for {arm}"
            );
        }
        assert!(
            body.contains("match first"),
            "parse_uri_proxy should dispatch with a match instead of one long prefix chain"
        );
        assert!(
            !body
                .trim_start()
                .starts_with("if starts_with_ascii_case_insensitive"),
            "parse_uri_proxy should not start by linearly checking every URI scheme"
        );
    }

    #[test]
    fn test_proxy_uri_needle_filters_schemes_by_first_byte() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn proxy_uri_needle_at_with_schemes")
            .nth(1)
            .and_then(|rest| rest.split("fn next_char_boundary").next())
            .expect("proxy_uri_needle_at_with_schemes body");

        assert!(
            body.contains("let first = bytes[0] | 0x20;"),
            "URI needle scanning should read the candidate first byte once"
        );
        let compact_body = body.split_whitespace().collect::<String>();
        assert!(
            compact_body.contains("(scheme[0]|0x20)==first"),
            "URI needle scanning should skip schemes whose first byte cannot match the candidate"
        );
        let first_filter = compact_body
            .find("(scheme[0]|0x20)==first")
            .expect("first-byte scheme filter");
        let full_compare = compact_body
            .find("bytes[..start].eq_ignore_ascii_case(scheme)")
            .expect("full scheme comparison");
        assert!(
            first_filter < full_compare,
            "URI needle scanning should apply first-byte filtering before full scheme comparisons"
        );
    }

    #[test]
    fn test_proxy_uri_needle_avoids_redundant_scheme_length_guard() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn proxy_uri_needle_at_with_schemes")
            .nth(1)
            .and_then(|rest| rest.split("fn next_char_boundary").next())
            .expect("proxy_uri_needle_at_with_schemes body");

        assert!(
            !body.contains("&& bytes.len() > scheme.len()"),
            "separator length checks already prove there are bytes after the scheme"
        );
        assert!(
            body.contains("bytes.len() >= start + separator.len()"),
            "URI needle scanning should keep the separator boundary check"
        );
    }

    #[test]
    fn test_proxy_uri_schemes_are_byte_slices_for_needle_scan() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn proxy_uri_needle_at_with_schemes")
            .nth(1)
            .and_then(|rest| rest.split("fn next_char_boundary").next())
            .expect("proxy_uri_needle_at_with_schemes body");

        assert!(
            source.contains("const PROXY_URI_SCHEMES: [&[u8]; 23]"),
            "primary URI schemes should be stored as byte slices"
        );
        assert!(
            source.contains("const EMBEDDED_PROXY_URI_SCHEMES: [&[u8]; 21]"),
            "embedded URI schemes should be stored as byte slices"
        );
        assert!(
            body.contains("schemes: &[&[u8]]"),
            "URI needle scanning should accept pre-byte-sliced schemes"
        );
        assert!(
            !body.contains("scheme.as_bytes()"),
            "URI needle scanning should not convert every scheme to bytes in the hot path"
        );
    }

    #[test]
    fn test_proxy_uri_needle_accepts_cached_text_bytes() {
        let source = include_str!("free_nodes.rs");
        let hint_body = source
            .split("fn proxy_uri_hint_with_schemes")
            .nth(1)
            .and_then(|rest| rest.split("fn decode_base64_text").next())
            .expect("proxy_uri_hint_with_schemes body");
        let parse_body = source
            .split("fn parse_uri_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_uri_proxy").next())
            .expect("parse_uri_proxies body");
        let needle_body = source
            .split("fn proxy_uri_needle_at_with_schemes")
            .nth(1)
            .and_then(|rest| rest.split("fn next_char_boundary").next())
            .expect("proxy_uri_needle_at_with_schemes body");

        assert!(
            source.contains("fn proxy_uri_needle_at(bytes: &[u8], index: usize) -> bool"),
            "single-scheme needle wrapper should accept cached text bytes"
        );
        assert!(
            source.contains(
                "fn proxy_uri_needle_at_with_schemes(bytes: &[u8], index: usize, schemes: &[&[u8]]) -> bool"
            ),
            "scheme needle scanner should accept cached text bytes"
        );
        assert!(
            hint_body.contains("proxy_uri_needle_at_with_schemes(text_bytes, cursor, schemes)"),
            "URI hint scanning should reuse its cached text bytes for needle checks"
        );
        assert!(
            parse_body.contains("proxy_uri_needle_at(text_bytes, cursor)"),
            "URI parsing should reuse its cached text bytes for needle checks"
        );
        assert!(
            !needle_body.contains("text.as_bytes()[index..]"),
            "needle scanning should not re-read text.as_bytes() for every candidate"
        );
    }

    #[test]
    fn test_next_char_boundary_uses_ascii_fast_path() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn next_char_boundary")
            .nth(1)
            .and_then(|rest| rest.split("fn find_proxy_uri_end").next())
            .expect("next_char_boundary body");

        assert!(
            body.contains("text.as_bytes()[index].is_ascii()"),
            "character boundary advancement should fast-path ASCII bytes before UTF-8 char parsing"
        );
    }

    #[test]
    fn test_uri_dedup_set_deduplicates_without_losing_hash_collisions() {
        let mut values = Vec::<String>::new();
        let mut seen = UriDedupSet::default();
        let fingerprint = DiscoveredUrlFingerprint { hash: 23, len: 23 };

        assert!(seen.insert_with_fingerprint(&values, "ss://one", fingerprint));
        values.push("ss://one".to_string());
        assert!(seen.insert_with_fingerprint(&values, "ss://two", fingerprint));
        values.push("ss://two".to_string());
        assert!(!seen.insert_with_fingerprint(&values, "ss://one", fingerprint));

        assert_eq!(values, vec!["ss://one", "ss://two"]);
    }

    #[test]
    fn test_parse_uri_proxies_decodes_html_entity_query_separators() {
        let text = r#"<a href="vless://00000000-0000-0000-0000-000000000000@example.net:8443?security=tls&amp;type=ws&amp;sni=sni.example.com#HTML%20Entity">node</a>"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_json_unicode_escaped_uri() {
        let text = r#"
<script>
{"link":"vless:\u002F\u002F00000000-0000-0000-0000-000000000000@example.net:8443\u003Fsecurity\u003Dtls\u0026type\u003Dws\u0026sni\u003Dsni.example.com\u0023Unicode%20Escaped"}
</script>
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
    }

    #[test]
    fn test_decode_proxy_uri_json_escape_matches_uppercase_hex_without_lowercase_call() {
        assert_eq!(decode_proxy_uri_json_escape(b'2', b'F'), Some('/'));
        assert_eq!(decode_proxy_uri_json_escape(b'3', b'A'), Some(':'));
        assert_eq!(decode_proxy_uri_json_escape(b'3', b'F'), Some('?'));
        assert_eq!(decode_proxy_uri_json_escape(b'3', b'D'), Some('='));
        assert_eq!(decode_proxy_uri_json_escape(b'2', b'6'), Some('&'));
        assert_eq!(decode_proxy_uri_json_escape(b'2', b'3'), Some('#'));
    }

    #[test]
    fn test_parse_uri_proxies_reads_html_numeric_entity_uri() {
        let text = r#"<a href="vless:&#x2F;&#x2F;00000000-0000-0000-0000-000000000000@example.net:8443&#x3F;security&#x3D;tls&#x26;type&#x3D;ws&#x26;sni&#x3D;sni.example.com&#x23;HTML%20Numeric">node</a>"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_html_named_entity_uri() {
        let text = r#"<a href="vless&colon;&sol;&sol;00000000-0000-0000-0000-000000000000@example.net:8443&quest;security&equals;tls&amp;type&equals;ws&amp;sni&equals;sni.example.com&num;HTML%20Named">node</a>"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_js_hex_escaped_uri() {
        let text = r#"
<script>
window.node = 'vless:\x2F\x2F00000000-0000-0000-0000-000000000000@example.net:8443\x3Fsecurity\x3Dtls\x26type\x3Dws\x26sni\x3Dsni.example.com\x23JS%20Hex';
</script>
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_percent_encoded_uri() {
        let text = r#"
<script>
window.node = "vless%3A%2F%2F00000000-0000-0000-0000-000000000000%40example.net%3A8443%3Fsecurity%3Dtls%26type%3Dws%26sni%3Dsni.example.com%23Percent%2520Encoded";
</script>
"#;

        let proxies = parse_proxies(text);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("network").and_then(string_value).as_deref(),
            Some("ws")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_ssr() {
        let password = URL_SAFE.encode("pass");
        let remarks = URL_SAFE.encode("SSR Node");
        let obfs_param = URL_SAFE.encode("obfs.example.com");
        let proto_param = URL_SAFE.encode("proto-token");
        let decoded = format!(
            "ssr.example.com:8388:origin:aes-256-cfb:plain:{password}/?remarks={remarks}&obfsparam={obfs_param}&protoparam={proto_param}"
        );
        let uri = format!("ssr://{}", URL_SAFE.encode(decoded));

        let proxies = parse_proxies(&uri);

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("ssr")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("ssr.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(8388));
        assert_eq!(
            proxy.get("cipher").and_then(string_value).as_deref(),
            Some("aes-256-cfb")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            proxy.get("protocol").and_then(string_value).as_deref(),
            Some("origin")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("obfs").and_then(string_value).as_deref(),
            Some("plain")
        );
        assert_eq!(
            proxy
                .get("protocol-param")
                .and_then(string_value)
                .as_deref(),
            Some("proto-token")
        );
        assert_eq!(
            proxy.get("obfs-param").and_then(string_value).as_deref(),
            Some("obfs.example.com")
        );
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("SSR Node")
        );
    }

    #[test]
    fn test_parse_ssr_proxy_splits_fields_without_temp_vec() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_ssr_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_ssr_query").next())
            .unwrap();

        assert!(!body.contains("Vec<&str>"));
        assert!(!body.contains(".collect()"));
    }

    #[test]
    fn test_uri_param_capacity_helpers_count_segments_without_allocation() {
        assert_eq!(query_pair_capacity(""), 0);
        assert_eq!(query_pair_capacity("remarks=a&protoparam=b&obfsparam=c"), 3);
        assert_eq!(
            delimited_tail_capacity("v2ray-plugin;mode=websocket;host=cdn;tls", b';'),
            3
        );
        assert_eq!(delimited_tail_capacity("obfs-local", b';'), 0);
        assert_eq!(csv_item_capacity("h2,http/1.1,h3"), 3);
        assert_eq!(csv_item_capacity("h2,,http/1.1,"), 4);
        assert_eq!(csv_item_capacity(""), 0);
    }

    #[test]
    fn test_uri_param_hash_maps_preallocate_hot_paths() {
        let source = include_str!("free_nodes.rs");
        let ss_plugin_body = source
            .split("fn insert_ss_plugin_param")
            .nth(1)
            .and_then(|rest| rest.split("fn insert_ss_v2ray_plugin_opts").next())
            .expect("insert_ss_plugin_param body");
        assert!(
            ss_plugin_body.contains("HashMap::with_capacity(delimited_tail_capacity(value, b';'))"),
            "SS plugin option parsing should preallocate by semicolon segment count"
        );

        let ssr_query_body = source
            .split("fn parse_ssr_query")
            .nth(1)
            .and_then(|rest| rest.split("fn decode_ssr_value").next())
            .expect("parse_ssr_query body");
        assert!(
            ssr_query_body.contains("HashMap::with_capacity(query_pair_capacity(query))"),
            "SSR query parsing should preallocate by query pair count"
        );
        assert!(
            !ssr_query_body.contains("let mut params = HashMap::new();"),
            "SSR query parsing should not start from an empty HashMap"
        );

        let vmess_transport_body = source
            .split("fn insert_vmess_transport_opts")
            .nth(1)
            .and_then(|rest| rest.split("fn normalize_vmess_network").next())
            .expect("insert_vmess_transport_opts body");
        assert!(
            vmess_transport_body.contains("HashMap::with_capacity(4)"),
            "vmess transport opts can reserve the bounded type/path/serviceName/host fields"
        );

        let csv_array_body = source
            .split("fn csv_array_value")
            .nth(1)
            .and_then(|rest| rest.split("fn string_values_array_value").next())
            .expect("csv_array_value body");
        assert!(
            csv_array_body.contains("Vec::with_capacity(csv_item_capacity(value))"),
            "CSV array parsing should preallocate by comma-delimited item count"
        );
        assert!(
            !csv_array_body.contains("let mut items = Vec::new();"),
            "CSV array parsing should not start from an empty Vec"
        );
    }

    #[test]
    fn test_annotated_host_port_parser_streams_tokens_without_collect() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_annotated_host_port_proxy_tokens")
            .nth(1)
            .and_then(|rest| rest.split("fn is_proxy_status_token").next())
            .expect("parse_annotated_host_port_proxy_tokens body");

        assert!(
            !body.contains("collect::<Vec"),
            "annotated host:port parser should stream whitespace tokens without collecting them"
        );
        assert!(
            body.contains("let mut first = None"),
            "annotated host:port parser should keep only a rolling three-token window"
        );
    }

    #[test]
    fn test_parse_user_info_proxy_borrows_proxy_type_name_fallback() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_user_info_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn normalize_proxy").next())
            .expect("parse_user_info_proxy body");

        assert!(
            body.contains("uri.fragment().unwrap_or(proxy_type)"),
            "user-info URI parsing should borrow proxy_type as the fallback name"
        );
        assert!(
            !body.contains("let fallback_name = proxy_type.to_string();"),
            "user-info URI parsing should not allocate a fallback String before checking fragment"
        );
    }

    #[test]
    fn test_server_port_uri_name_fallbacks_are_lazy() {
        let source = include_str!("free_nodes.rs");
        let anytls_body = source
            .split("fn parse_anytls_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_mierus_proxies").next())
            .expect("parse_anytls_proxy body");
        assert!(
            anytls_body.contains("unwrap_or_else(|| format!(\"{server}:{port}\"))"),
            "anytls should build server:port fallback only when fragment is absent or empty"
        );
        assert!(
            !anytls_body.contains("let fallback_name = format!"),
            "anytls should not eagerly allocate a fallback name"
        );

        let http_body = source
            .split("fn parse_http_proxy")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_hysteria_proxy").next())
            .expect("parse_http_proxy body");
        assert!(
            http_body.contains("unwrap_or_else(|| format!(\"{server}:{port}\"))"),
            "http should build server:port fallback only when fragment is absent or empty"
        );
        assert!(
            !http_body.contains("let fallback_name = format!"),
            "http should not eagerly allocate a fallback name"
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_tuic_v5() {
        let proxies = parse_proxies(
            "tuic://uuid-123:pass-456@tuic.example.com:443?congestion_control=bbr&udp_relay_mode=native&alpn=h3,h4&sni=sni.example.com#TUIC%20V5",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("tuic")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("tuic.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("uuid").and_then(string_value).as_deref(),
            Some("uuid-123")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass-456")
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy
                .get("congestion-controller")
                .and_then(string_value)
                .as_deref(),
            Some("bbr")
        );
        assert_eq!(
            proxy
                .get("udp-relay-mode")
                .and_then(string_value)
                .as_deref(),
            Some("native")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            proxy.get("alpn").and_then(Value::as_array).map(Vec::len),
            Some(2)
        );
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("TUIC V5")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_tuic_extra_params() {
        let proxies = parse_proxies(
            "tuic://uuid-123:pass-456@tuic-extra.example.com:443?allow_insecure=1&fp=chrome&reduce_rtt=1&heartbeat_interval=10000&request_timeout=8000&udp_over_stream=1&udp_over_stream_version=2&max_open_streams=20&max_udp_relay_packet_size=1500#TUIC%20Extra",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("tuic-extra.example.com")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("chrome")
        );
        assert_eq!(proxy.get("reduce-rtt").and_then(Value::as_bool), Some(true));
        assert_eq!(
            proxy.get("heartbeat-interval").and_then(Value::as_i64),
            Some(10000)
        );
        assert_eq!(
            proxy.get("request-timeout").and_then(Value::as_i64),
            Some(8000)
        );
        assert_eq!(
            proxy.get("udp-over-stream").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy.get("udp-over-stream-version").and_then(Value::as_i64),
            Some(2)
        );
        assert_eq!(
            proxy.get("max-open-streams").and_then(Value::as_i64),
            Some(20)
        );
        assert_eq!(
            proxy
                .get("max-udp-relay-packet-size")
                .and_then(Value::as_i64),
            Some(1500)
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_tuic_v4_token() {
        let proxies = parse_proxies(
            "tuic://token-123@tuic.example.com:8443?disable_sni=1&udp_relay_mode=quic#TUIC%20V4",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("tuic")
        );
        assert_eq!(
            proxy.get("token").and_then(string_value).as_deref(),
            Some("token-123")
        );
        assert!(proxy.get("uuid").is_none());
        assert!(proxy.get("password").is_none());
        assert_eq!(
            proxy.get("disable-sni").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(
            proxy
                .get("udp-relay-mode")
                .and_then(string_value)
                .as_deref(),
            Some("quic")
        );
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("TUIC V4")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_snell() {
        let proxies = parse_proxies(
            "snell://psk-value@snell.example.com:44046?version=3&obfs=http&obfs-host=www.bing.com#Snell%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("snell")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("snell.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(44046));
        assert_eq!(
            proxy.get("psk").and_then(string_value).as_deref(),
            Some("psk-value")
        );
        assert_eq!(proxy.get("version").and_then(Value::as_i64), Some(3));
        let obfs_opts = proxy
            .get("obfs-opts")
            .and_then(Value::as_object)
            .expect("snell obfs opts");
        assert_eq!(
            obfs_opts.get("mode").and_then(string_value).as_deref(),
            Some("http")
        );
        assert_eq!(
            obfs_opts.get("host").and_then(string_value).as_deref(),
            Some("www.bing.com")
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_hysteria_v1() {
        let proxies = parse_proxies(
            "hysteria://hy.example.com:8443?auth=secret&peer=sni.example.com&protocol=udp&upmbps=100&downmbps=200&ports=8443,9443-9555&obfs-protocol=wechat-video&alpn=h3,h4&obfs=obfs-pass&insecure=1#HY%20V1",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("hysteria")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("hy.example.com")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(8443));
        assert_eq!(
            proxy.get("auth_str").and_then(string_value).as_deref(),
            Some("secret")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            proxy.get("protocol").and_then(string_value).as_deref(),
            Some("udp")
        );
        assert_eq!(
            proxy.get("up").and_then(string_value).as_deref(),
            Some("100")
        );
        assert_eq!(
            proxy.get("down").and_then(string_value).as_deref(),
            Some("200")
        );
        assert_eq!(
            proxy.get("ports").and_then(string_value).as_deref(),
            Some("8443,9443-9555")
        );
        assert_eq!(
            proxy.get("obfs-protocol").and_then(string_value).as_deref(),
            Some("wechat-video")
        );
        assert_eq!(
            proxy.get("alpn").and_then(Value::as_array).map(Vec::len),
            Some(2)
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_hysteria_v1_scheme_aliases() {
        let proxies = parse_proxies(
            "hy://hy-short.example.com:8443?auth=secret&protocol=udp&upmbps=100&downmbps=200#HY%20Short\nhysteria1://hy-one.example.com:9443?auth=secret2&peer=sni.example.com&insecure=1#HY%20One",
        );

        assert_eq!(proxies.len(), 2);
        let short = &proxies[0];
        assert_eq!(
            short.get("type").and_then(string_value).as_deref(),
            Some("hysteria")
        );
        assert_eq!(
            short.get("server").and_then(string_value).as_deref(),
            Some("hy-short.example.com")
        );
        assert_eq!(short.get("port").and_then(parse_port), Some(8443));
        assert_eq!(
            short.get("auth_str").and_then(string_value).as_deref(),
            Some("secret")
        );
        assert_eq!(
            short.get("up").and_then(string_value).as_deref(),
            Some("100")
        );
        assert_eq!(
            short.get("down").and_then(string_value).as_deref(),
            Some("200")
        );

        let hysteria1 = &proxies[1];
        assert_eq!(
            hysteria1.get("type").and_then(string_value).as_deref(),
            Some("hysteria")
        );
        assert_eq!(
            hysteria1.get("server").and_then(string_value).as_deref(),
            Some("hy-one.example.com")
        );
        assert_eq!(hysteria1.get("port").and_then(parse_port), Some(9443));
        assert_eq!(
            hysteria1.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            hysteria1.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_hysteria2_full_fields() {
        let proxies = parse_proxies(
            "hysteria2://letmein@example.com:443/?insecure=1&obfs=salamander&obfs-password=gawrgura&pinSHA256=65b3&sni=real.example.com&up=114&down=514&mport=443,8443-8445&hop-interval=30&alpn=h3,h4#hy2test",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("hysteria2")
        );
        assert_eq!(proxy.get("port").and_then(parse_port), Some(443));
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("letmein")
        );
        assert_eq!(
            proxy.get("obfs").and_then(string_value).as_deref(),
            Some("salamander")
        );
        assert_eq!(
            proxy.get("obfs-password").and_then(string_value).as_deref(),
            Some("gawrgura")
        );
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("65b3")
        );
        assert_eq!(
            proxy.get("up").and_then(string_value).as_deref(),
            Some("114")
        );
        assert_eq!(
            proxy.get("down").and_then(string_value).as_deref(),
            Some("514")
        );
        assert_eq!(
            proxy.get("ports").and_then(string_value).as_deref(),
            Some("443,8443-8445")
        );
        assert_eq!(
            proxy.get("hop-interval").and_then(string_value).as_deref(),
            Some("30")
        );
        assert_eq!(
            proxy.get("alpn").and_then(Value::as_array).map(Vec::len),
            Some(2)
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_anytls() {
        let proxies = parse_proxies(
            "anytls://user:pass@anytls.example.com:8443?sni=sni.example.com&hpkp=fp-value&insecure=1#AnyTLS%20Node",
        );

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("anytls")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("anytls.example.com")
        );
        assert_eq!(proxy.get("port").and_then(Value::as_i64), Some(8443));
        assert_eq!(
            proxy.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            proxy.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            proxy.get("sni").and_then(string_value).as_deref(),
            Some("sni.example.com")
        );
        assert_eq!(
            proxy.get("fingerprint").and_then(string_value).as_deref(),
            Some("fp-value")
        );
        assert_eq!(
            proxy.get("skip-cert-verify").and_then(Value::as_bool),
            Some(true)
        );
        assert_eq!(proxy.get("udp").and_then(Value::as_bool), Some(true));
    }

    #[test]
    fn test_parse_uri_proxies_reads_mierus() {
        let proxies = parse_proxies(
            "mierus://user:pass@mieru.example.com?handshake-mode=HANDSHAKE_NO_WAIT&multiplexing=MULTIPLEXING_HIGH&port=6666&port=9998-9999&profile=default&protocol=TCP&protocol=UDP&traffic-pattern=CCoQARoECAEQCiIYCAMQASoIMDAwMTAyMDMqCDA0MDUwNjA3#Mieru",
        );

        assert_eq!(proxies.len(), 2);
        let first = &proxies[0];
        assert_eq!(
            first.get("type").and_then(string_value).as_deref(),
            Some("mieru")
        );
        assert_eq!(
            first.get("name").and_then(string_value).as_deref(),
            Some("Mieru:6666/TCP")
        );
        assert_eq!(
            first.get("server").and_then(string_value).as_deref(),
            Some("mieru.example.com")
        );
        assert_eq!(first.get("port").and_then(Value::as_i64), Some(6666));
        assert_eq!(
            first.get("transport").and_then(string_value).as_deref(),
            Some("TCP")
        );
        assert_eq!(
            first.get("username").and_then(string_value).as_deref(),
            Some("user")
        );
        assert_eq!(
            first.get("password").and_then(string_value).as_deref(),
            Some("pass")
        );
        assert_eq!(
            first.get("multiplexing").and_then(string_value).as_deref(),
            Some("MULTIPLEXING_HIGH")
        );
        assert_eq!(
            first
                .get("handshake-mode")
                .and_then(string_value)
                .as_deref(),
            Some("HANDSHAKE_NO_WAIT")
        );
        assert_eq!(
            first
                .get("traffic-pattern")
                .and_then(string_value)
                .as_deref(),
            Some("CCoQARoECAEQCiIYCAMQASoIMDAwMTAyMDMqCDA0MDUwNjA3")
        );

        let second = &proxies[1];
        assert_eq!(
            second.get("name").and_then(string_value).as_deref(),
            Some("Mieru:9998-9999/UDP")
        );
        assert_eq!(
            second.get("port-range").and_then(string_value).as_deref(),
            Some("9998-9999")
        );
        assert_eq!(
            second.get("transport").and_then(string_value).as_deref(),
            Some("UDP")
        );
    }

    #[test]
    fn test_parse_mierus_proxies_preallocates_port_protocol_vectors() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn parse_mierus_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn parse_socks_proxy").next())
            .expect("parse_mierus_proxies body");

        assert!(
            body.contains(
                "let query_capacity = uri.query().map(query_pair_capacity).unwrap_or(0);"
            ),
            "Mieru URI parsing should derive port/protocol vector capacity from query pair count"
        );
        assert!(
            body.contains("let mut ports = Vec::with_capacity(query_capacity);"),
            "Mieru URI parsing should preallocate ports for multi-port subscriptions"
        );
        assert!(
            body.contains("let mut protocols = Vec::with_capacity(query_capacity);"),
            "Mieru URI parsing should preallocate protocols for multi-protocol subscriptions"
        );
        assert!(
            !body.contains("let mut ports = Vec::new();"),
            "Mieru ports should not start from an empty Vec"
        );
        assert!(
            !body.contains("let mut protocols = Vec::new();"),
            "Mieru protocols should not start from an empty Vec"
        );
    }

    #[test]
    fn test_parse_uri_proxies_reads_mieru_scheme_alias() {
        let proxies =
            parse_proxies("mieru://user:pass@mieru.example.com?port=2999&protocol=TCP#Mieru");

        assert_eq!(proxies.len(), 1);
        let proxy = &proxies[0];
        assert_eq!(
            proxy.get("type").and_then(string_value).as_deref(),
            Some("mieru")
        );
        assert_eq!(
            proxy.get("name").and_then(string_value).as_deref(),
            Some("Mieru:2999/TCP")
        );
        assert_eq!(
            proxy.get("server").and_then(string_value).as_deref(),
            Some("mieru.example.com")
        );
        assert_eq!(proxy.get("port").and_then(Value::as_i64), Some(2999));
        assert_eq!(
            proxy.get("transport").and_then(string_value).as_deref(),
            Some("TCP")
        );
    }

    #[test]
    fn test_parse_proxies_reads_embedded_base64_subscription_block() {
        let encoded = STANDARD.encode("ss://aes-128-gcm:pass@example.com:443#Embedded");
        let text = format!("<script>window.__sub = '{encoded}';</script>");

        let proxies = parse_proxies(&text);

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0].get("server").and_then(string_value).as_deref(),
            Some("example.com")
        );
    }

    #[test]
    fn test_parse_proxies_hints_keep_yaml_json_and_uri_inputs() {
        assert!(has_yaml_proxy_collection_hint(
            "proxies :\n  - name: spaced\n"
        ));
        assert!(has_yaml_proxy_collection_hint("proxy:\n  name: legacy\n"));
        assert!(has_yaml_proxy_collection_hint(
            r#"{"payload":[{"name":"json"}]}"#
        ));
        assert!(has_yaml_proxy_collection_hint(
            r#"{"outbounds":[{"type":"direct"}]}"#
        ));
        assert!(has_yaml_proxy_collection_hint(
            r#"[{"name":"json","type":"ss","server":"json.example.com"}]"#
        ));
        assert!(has_proxy_uri_hint(
            "vless://00000000-0000-0000-0000-000000000000@example.com:443#Node"
        ));
        assert!(!has_yaml_proxy_collection_hint(
            "plain web page with proxyless content"
        ));
        assert!(!decoded_has_proxy_payload_hint(
            "https://example.com/not-a-proxy-subscription-page"
        ));

        let yaml = "proxies :\n  - name: spaced\n    type: ss\n    server: spaced.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n";
        let uri = "ss://aes-128-gcm:pass@uri.example.com:443#Uri";

        assert_eq!(parse_proxies(yaml).len(), 1);
        assert_eq!(parse_proxies(uri).len(), 1);
    }

    #[test]
    fn test_yaml_proxy_collection_hint_scans_collection_keys_once() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn has_yaml_proxy_collection_hint")
            .nth(1)
            .and_then(|rest| rest.split("fn has_root_yaml_proxy_list_hint").next())
            .expect("yaml proxy collection hint body");

        assert!(
            !body.contains("has_yaml_key_hint(text, \"proxies\")"),
            "YAML collection hint should not rescan large text for proxies"
        );
        assert!(
            body.contains("yaml_proxy_collection_keys(text)"),
            "YAML collection hint should reuse a single collection-key scan"
        );
        assert!(has_yaml_proxy_collection_hint(
            "payload:\n  - ss://aes-128-gcm:pass@example.com:443#Payload\n"
        ));
        assert!(has_yaml_proxy_collection_hint(
            "outbounds:\n  - type: direct\n"
        ));
    }

    #[test]
    fn test_yaml_proxy_collection_hint_dispatches_root_lists_before_collection_scan() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn has_yaml_proxy_collection_hint")
            .nth(1)
            .and_then(|rest| {
                rest.split("#[derive(Default)]\nstruct YamlProxyCollectionKeys")
                    .next()
            })
            .expect("yaml proxy collection hint body");

        let json_branch = body
            .split("Some(b'[')")
            .nth(1)
            .and_then(|rest| rest.split("_ =>").next())
            .expect("root json branch");
        let root_json_index = json_branch
            .find("has_root_json_proxy_list_hint(text)")
            .expect("root json dispatch");
        let collection_index = json_branch
            .find("yaml_proxy_collection_keys(text)")
            .expect("collection key fallback");
        assert!(
            root_json_index < collection_index,
            "root JSON/YAML list hints should run before the collection-key scan"
        );
        assert!(
            body.contains("first_non_ws_byte(text)"),
            "YAML collection hint should dispatch by the first non-whitespace byte"
        );
        assert!(has_yaml_proxy_collection_hint(
            "  [{\"name\":\"json\",\"type\":\"ss\",\"server\":\"json.example.com\"}]"
        ));
        assert!(has_yaml_proxy_collection_hint(
            "  - name: yaml\n    type: ss\n    server: yaml.example.com\n"
        ));
        assert!(has_yaml_proxy_collection_hint(
            "metadata:\n  title: page\nproxies:\n  - name: mapped\n"
        ));
    }

    #[test]
    fn test_root_json_proxy_list_hint_scans_fields_once() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn has_root_json_proxy_list_hint")
            .nth(1)
            .and_then(|rest| rest.split("fn has_root_sing_box_outbound_list_hint").next())
            .expect("root json proxy list hint body");

        assert!(
            !body.contains("contains_ascii_case_insensitive(text, \"\\\"protocol\\\"\")"),
            "root JSON proxy-list hint should not rescan large JSON text for protocol"
        );
        assert!(
            body.contains("root_json_proxy_list_keys(text)"),
            "root JSON proxy-list hint should reuse a single field-key scan"
        );
    }

    #[test]
    fn test_root_json_proxy_list_hint_requires_port_or_host_port_endpoint() {
        assert!(!has_root_json_proxy_list_hint(
            r#"[{"protocol":"http","host":"metadata.example.com"}]"#
        ));
        assert!(has_root_json_proxy_list_hint(
            r#"[{"protocol":"http","host":"metadata.example.com:8080"}]"#
        ));
        assert!(has_root_json_proxy_list_hint(
            r#"[{"type":"socks5","address":"[2001:db8::2]:1080"}]"#
        ));
        assert!(has_root_json_proxy_list_hint(
            r#"[{"scheme":"https","host":"edge.example.com","port":8443}]"#
        ));
    }

    #[test]
    fn test_root_yaml_proxy_list_hint_scans_fields_once() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn has_root_yaml_proxy_list_hint")
            .nth(1)
            .and_then(|rest| rest.split("fn has_root_json_proxy_list_hint").next())
            .expect("root yaml proxy list hint body");

        assert!(
            !body.contains("has_yaml_key_hint(text, \"name\")"),
            "root YAML proxy-list hint should not rescan large text for name"
        );
        assert!(
            body.contains("root_yaml_proxy_list_keys(text)"),
            "root YAML proxy-list hint should reuse a single field-key scan"
        );
        assert!(has_yaml_proxy_collection_hint(
            "- name: yaml-node\n  type: ss\n  server: yaml.example.com\n"
        ));
    }

    #[test]
    fn test_root_sing_box_outbound_list_hint_scans_fields_once() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn has_root_sing_box_outbound_list_hint")
            .nth(1)
            .and_then(|rest| rest.split("fn has_yaml_key_hint").next())
            .expect("root sing-box outbound list hint body");

        assert!(
            !body.contains("has_yaml_key_hint(text, \"type\")"),
            "root sing-box outbound hint should not rescan large text for type"
        );
        assert!(
            body.contains("root_sing_box_outbound_keys(text)"),
            "root sing-box outbound hint should reuse a single field-key scan"
        );
        assert!(has_yaml_proxy_collection_hint(
            r#"[{"type":"hysteria","server":"hy.example.com","server_port":443}]"#
        ));
        assert!(has_yaml_proxy_collection_hint(
            "- type: hysteria\n  server: hy.example.com\n  port: 443\n"
        ));
    }

    #[test]
    fn test_config_extension_checks_path_case_and_query_without_allocating_lowercase() {
        assert!(has_config_extension(
            "https://example.com/free/Clash.YAML?token=a#daily"
        ));
        assert!(has_config_extension("../daily/free.YML?target=clash"));
        assert!(has_config_extension("subscriptions/list.TxT#latest"));
        assert!(has_config_extension(
            "sing-box/Outbounds.JsOn?target=sing-box"
        ));
        assert!(!has_config_extension("assets/logo.yaml.png?target=clash"));
        assert!(!has_config_extension(
            "https://example.com/api/sub?format=clash"
        ));
    }

    #[test]
    fn test_candidate_checks_keep_mixed_case_without_lowercase_copy() {
        assert!(is_strong_config_candidate(
            "HTTPS://RAW.GITHUBUSERCONTENT.COM/owner/repo/main/Clash.YAML?TOKEN=A"
        ));
        assert!(is_strong_config_candidate(
            "https://example.com/free/sing-box.JSON"
        ));
        assert!(is_strong_config_candidate(
            "https://example.com/API/Subscribe?Target=Clash"
        ));
        assert!(!is_strong_config_candidate(
            "https://API.GITHUB.COM/repos/owner/repo/GIT/TREES/main?recursive=1"
        ));

        assert!(is_page_candidate(
            "HTTPS://example.com/Free-Node/Daily-List.HTML"
        ));
        assert!(!is_page_candidate("https://example.com/ASSETS/LOGO.PNG"));
        assert!(!is_page_candidate(
            "https://cdn.example.com/images/logo.PNG?version=20260620"
        ));
        assert!(!is_page_candidate(
            "https://cdn.example.com/styles/app.css#main"
        ));
        assert!(!is_page_candidate(
            "https://example.com/download/Clash.YML?token=a"
        ));

        let source = CandidateSource {
            id: "mixed".into(),
            label: "Mixed".into(),
            seed: "https://example.com/free-node/".into(),
            rank: 1,
            update_interval_hours: 24,
            page_discovery: true,
        };
        assert!(is_relevant_same_host_script_candidate(
            "https://example.com/static/FreeSubscribe.JS",
            &source.seed
        ));
        assert!(!is_relevant_same_host_script_candidate(
            "https://cdn.example.com/static/FreeSubscribe.JS",
            &source.seed
        ));
    }

    #[test]
    fn test_is_page_candidate_uses_direct_raw_github_hint_check() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn is_page_candidate")
            .and_then(|(_, rest)| rest.split_once("fn is_discovery_page_candidate"))
            .map(|(body, _)| body)
            .expect("is_page_candidate body");

        assert!(
            body.contains("contains_ascii_case_insensitive(url, \"raw.githubusercontent.com\")")
        );
        assert!(!body.contains("RAW_GITHUB_HOST_HINT"));
        assert!(!is_page_candidate(
            "https://raw.githubusercontent.com/owner/repo/main/index.html"
        ));
        assert!(is_page_candidate("https://example.com/free-node/"));
    }

    #[test]
    fn test_contains_ascii_case_insensitive_uses_ascii_fast_path() {
        assert!(contains_ascii_case_insensitive(
            "prefix HTTPS://EXAMPLE.COM/Daily/Free.YAML",
            "https://example.com"
        ));
        assert!(contains_ascii_case_insensitive(
            "downloadUrl",
            "downloadurl"
        ));
        assert!(!contains_ascii_case_insensitive(
            "plain web page without a config marker",
            "subscription"
        ));
        assert!(!contains_ascii_case_insensitive("anything", ""));
        assert!(!contains_ascii_case_insensitive("short", "longer needle"));
    }

    #[test]
    fn test_contains_any_ascii_case_insensitive_covers_discovery_attribute_hints() {
        assert!(contains_any_ascii_case_insensitive(
            r#"<a HREF="/daily/free.yaml">free</a>"#,
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
        assert!(contains_any_ascii_case_insensitive(
            r#"<button DATA-SUB="/api/free">copy</button>"#,
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
        assert!(contains_any_ascii_case_insensitive(
            r#"{"downloadUrl":"https://example.com/free.yaml"}"#,
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
        assert!(contains_any_ascii_case_insensitive(
            r#"{"download-url":"https://example.com/free.yaml"}"#,
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
        assert!(contains_any_ascii_case_insensitive(
            r#"{"download_url":"https://example.com/free.yaml"}"#,
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
        assert!(contains_any_ascii_case_insensitive(
            r#"{"HTML_URL":"https://example.com/releases"}"#,
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
        assert!(!contains_any_ascii_case_insensitive(
            "plain content without subscription attributes",
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
        assert!(!contains_any_ascii_case_insensitive("anything", &[]));
        assert!(!contains_any_ascii_case_insensitive(
            "",
            &DISCOVERY_ATTRIBUTE_HINTS
        ));
    }

    #[test]
    fn test_contains_any_ascii_case_insensitive_prefilters_first_bytes() {
        let sparse_text = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx DATA-SUB=/api/free";
        assert!(contains_any_ascii_case_insensitive(
            sparse_text,
            &["", "download_url", "data-sub"]
        ));
        assert!(!contains_any_ascii_case_insensitive(
            "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
            &["", "download_url", "data-sub"]
        ));
        assert!(contains_any_ascii_case_insensitive(
            "prefix HTML_URL suffix",
            &["html_url"]
        ));
    }

    #[test]
    fn test_contains_any_ascii_case_insensitive_covers_candidate_hint_groups() {
        assert!(has_provider_followup_hint(
            "proxy-providers:\n  daily:\n    url: https://example.com/sub.yaml"
        ));
        assert!(has_provider_followup_hint(
            "Providers:\n  daily:\n    url: https://example.com/sub.yaml"
        ));
        assert!(markdown_label_has_subscription_context(
            "Daily Clash Subscription"
        ));
        assert!(markdown_label_has_subscription_context("免费节点"));
        assert!(is_subscription_field_key("download-url"));
        assert!(is_subscription_field_key("source_url"));
        assert!(is_relative_config_candidate(
            "/api/v1/subscribe?target=clash"
        ));
        assert!(is_contextual_relative_config_candidate(
            "profiles/free-node.txt"
        ));
        assert!(is_strong_config_candidate(
            "https://example.com/client?suburl=https%3A%2F%2Fsub.example.com"
        ));
        assert!(!has_provider_followup_hint("plain web page"));
        assert!(!markdown_label_has_subscription_context("release notes"));
        assert!(!is_subscription_field_key("asset_url"));
        assert!(!is_contextual_relative_config_candidate(
            "assets/banner.png"
        ));
    }

    #[test]
    fn test_decode_candidates_borrows_original_and_decodes_compact_base64_once() {
        let encoded = STANDARD.encode("ss://aes-128-gcm:pass@example.com:443#Compact");

        let candidates = decode_candidates(&encoded);

        assert_eq!(candidates.len(), 2);
        assert!(matches!(candidates[0], std::borrow::Cow::Borrowed(_)));
        assert_eq!(candidates[0].as_ref(), encoded);
        assert_eq!(
            candidates[1].as_ref(),
            "ss://aes-128-gcm:pass@example.com:443#Compact"
        );
    }

    #[test]
    fn test_decode_candidates_decodes_decimal_byte_stream_once() {
        let encoded = "116 114 111 106 97 110 58 47 47 112 97 115 115 64 100 101 99 105 109 97 108 46 101 120 97 109 112 108 101 46 99 111 109 58 52 52 51 35 68 101 99 105 109 97 108";

        let candidates = decode_candidates(encoded);

        assert_eq!(candidates.len(), 2);
        assert!(matches!(candidates[0], std::borrow::Cow::Borrowed(_)));
        assert_eq!(candidates[0].as_ref(), encoded);
        assert_eq!(
            candidates[1].as_ref(),
            "trojan://pass@decimal.example.com:443#Decimal"
        );
    }

    #[test]
    fn test_decode_compact_base64_text_scans_bytes_without_char_iteration() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn decode_compact_base64_text")
            .nth(1)
            .and_then(|rest| rest.split("fn visit_embedded_base64_candidates").next())
            .expect("decode_compact_base64_text body");
        let chars_call = concat!(".", "chars()");

        assert!(!body.contains(chars_call));
        assert!(body.contains("is_base64_byte"));
    }

    #[test]
    fn test_visit_decoded_candidates_keeps_order_without_collecting_first() {
        let encoded = STANDARD.encode("ss://aes-128-gcm:pass@example.com:443#Stream");
        let mut visited = Vec::<String>::new();

        visit_decoded_candidates(&encoded, |candidate| {
            visited.push(candidate.as_ref().to_string());
        });

        assert_eq!(
            visited,
            vec![
                encoded,
                "ss://aes-128-gcm:pass@example.com:443#Stream".to_string()
            ]
        );
    }

    #[test]
    fn test_visit_decoded_candidates_lazily_initializes_decoded_buffers() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn visit_decoded_candidates")
            .nth(1)
            .and_then(|rest| rest.split("struct DecodedCandidateIndex").next())
            .expect("visit_decoded_candidates body");

        assert!(
            !body.contains("Vec::<String>::with_capacity(DECODED_CANDIDATE_LIMIT)"),
            "plain text visits should not preallocate decoded candidate storage"
        );
        assert!(
            !body.contains("DecodedCandidateIndex::with_capacity(DECODED_CANDIDATE_LIMIT)"),
            "plain text visits should not preallocate decoded candidate dedup index"
        );
        assert!(
            body.contains("DecodedCandidateStorage::default()"),
            "decoded candidate storage should be lazily initialized"
        );
        assert!(
            body.contains("push_and_visit"),
            "decoded values should initialize only when a decoded candidate is accepted"
        );

        let plain_text = "plain text without base64 candidates";
        let mut visited = Vec::<String>::new();
        visit_decoded_candidates(plain_text, |candidate| {
            visited.push(candidate.as_ref().to_string());
        });
        assert_eq!(
            visited,
            vec![plain_text.to_string()],
            "plain text should visit only the borrowed original input"
        );
    }

    #[test]
    fn test_decoded_candidate_index_with_capacity_preallocates_buckets() {
        let index = DecodedCandidateIndex::with_capacity(DECODED_CANDIDATE_LIMIT);

        assert!(index.capacity() >= DECODED_CANDIDATE_LIMIT);
    }

    #[test]
    fn test_decoded_candidate_index_deduplicates_without_losing_hash_collisions() {
        let values = insert_decoded_candidates_with_forced_fingerprint_for_testing([
            "ss://aes-128-gcm:pass@example.com:443#A",
            "ss://aes-128-gcm:pass@example.com:443#B",
            "ss://aes-128-gcm:pass@example.com:443#A",
        ]);

        assert_eq!(
            values,
            vec![
                "ss://aes-128-gcm:pass@example.com:443#A".to_string(),
                "ss://aes-128-gcm:pass@example.com:443#B".to_string(),
            ]
        );
    }

    #[test]
    fn test_deduplicate_and_name_removes_same_endpoint() {
        let mut proxy = Map::new();
        proxy.insert("name".into(), json!("A"));
        proxy.insert("type".into(), json!("ss"));
        proxy.insert("server".into(), json!("example.com"));
        proxy.insert("port".into(), json!(443));
        proxy.insert("cipher".into(), json!("aes"));
        proxy.insert("password".into(), json!("pass"));

        let proxies = deduplicate_and_name(vec![
            DatedProxy {
                proxy: proxy.clone(),
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
            DatedProxy {
                proxy,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
        ]);

        assert_eq!(proxies.len(), 1);
    }

    #[test]
    fn test_deduplicate_and_name_keeps_same_endpoint_from_different_sources() {
        let mut proxy = Map::new();
        proxy.insert("name".into(), json!("shared"));
        proxy.insert("type".into(), json!("ss"));
        proxy.insert("server".into(), json!("shared.example.com"));
        proxy.insert("port".into(), json!(443));
        proxy.insert("cipher".into(), json!("aes"));
        proxy.insert("password".into(), json!("pass"));

        let proxies = deduplicate_and_name(vec![
            DatedProxy {
                proxy: proxy.clone(),
                date_label: "2026-07-12".into(),
                date_token: 20260712,
                source_id: Some("source-a".into()),
                source_label: Some("Source A".into()),
            },
            DatedProxy {
                proxy,
                date_label: "2026-07-12".into(),
                date_token: 20260712,
                source_id: Some("source-b".into()),
                source_label: Some("Source B".into()),
            },
        ]);
        let yaml = build_clash_yaml(&proxies, 20260712, false).unwrap();

        assert_eq!(proxies.len(), 2);
        assert!(yaml.contains("来源 Source A"));
        assert!(yaml.contains("来源 Source B"));
    }

    #[test]
    fn test_deduplicate_and_name_matches_endpoint_case_insensitively_without_join_copy() {
        let mut first = Map::new();
        first.insert("name".into(), json!("A"));
        first.insert("type".into(), json!("SS"));
        first.insert("server".into(), json!("EDGE.EXAMPLE.COM"));
        first.insert("port".into(), json!(443));
        first.insert("cipher".into(), json!("AES"));
        first.insert("password".into(), json!("PASS"));
        first.insert("sni".into(), json!("CDN.EXAMPLE.COM"));

        let mut second = Map::new();
        second.insert("name".into(), json!("B"));
        second.insert("type".into(), json!("ss"));
        second.insert("server".into(), json!("edge.example.com"));
        second.insert("port".into(), json!(443));
        second.insert("cipher".into(), json!("aes"));
        second.insert("password".into(), json!("pass"));
        second.insert("sni".into(), json!("cdn.example.com"));

        let proxies = deduplicate_and_name(vec![
            DatedProxy {
                proxy: first,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
            DatedProxy {
                proxy: second,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
        ]);

        assert_eq!(proxies.len(), 1);
    }

    #[test]
    fn test_deduplicate_and_name_borrows_string_names_and_keeps_scalar_names() {
        let mut named = Map::new();
        named.insert("name".into(), json!("  Fast Node  "));
        named.insert("type".into(), json!("ss"));
        named.insert("server".into(), json!("a.example.com"));
        named.insert("port".into(), json!(1001));
        named.insert("cipher".into(), json!("aes"));
        named.insert("password".into(), json!("pass-a"));

        let mut numeric_name = Map::new();
        numeric_name.insert("name".into(), json!(443));
        numeric_name.insert("type".into(), json!("trojan"));
        numeric_name.insert("server".into(), json!("b.example.com"));
        numeric_name.insert("port".into(), json!(1002));
        numeric_name.insert("password".into(), json!("pass-b"));

        let mut fallback = Map::new();
        fallback.insert("type".into(), json!("VMess"));
        fallback.insert("server".into(), json!("HOST.EXAMPLE.COM"));
        fallback.insert("port".into(), json!(1003));
        fallback.insert("uuid".into(), json!("uuid-c"));

        let proxies = deduplicate_and_name(vec![
            DatedProxy {
                proxy: named,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
            DatedProxy {
                proxy: numeric_name,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
            DatedProxy {
                proxy: fallback,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
        ]);

        let names = proxies
            .iter()
            .filter_map(|item| item.proxy.get("name").and_then(Value::as_str))
            .collect::<Vec<_>>();
        assert_eq!(names, ["Fast Node", "443", "VMess-HOST.EXAMPLE.COM"]);
    }

    #[test]
    fn test_deduplicate_and_name_preallocated_collections_keep_order_and_suffixes() {
        let mut first = Map::new();
        first.insert("name".into(), json!("节点"));
        first.insert("type".into(), json!("ss"));
        first.insert("server".into(), json!("a.example.com"));
        first.insert("port".into(), json!(1001));
        first.insert("cipher".into(), json!("aes"));
        first.insert("password".into(), json!("pass-a"));

        let mut second = Map::new();
        second.insert("name".into(), json!("节点"));
        second.insert("type".into(), json!("trojan"));
        second.insert("server".into(), json!("b.example.com"));
        second.insert("port".into(), json!(1002));
        second.insert("password".into(), json!("pass-b"));

        let mut duplicate = Map::new();
        duplicate.insert("name".into(), json!("重复"));
        duplicate.insert("type".into(), json!("SS"));
        duplicate.insert("server".into(), json!("A.EXAMPLE.COM"));
        duplicate.insert("port".into(), json!(1001));
        duplicate.insert("cipher".into(), json!("AES"));
        duplicate.insert("password".into(), json!("PASS-A"));

        let proxies = deduplicate_and_name(vec![
            DatedProxy {
                proxy: first,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
            DatedProxy {
                proxy: second,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
            DatedProxy {
                proxy: duplicate,
                date_label: "2026-06-14".into(),
                date_token: 20260614,
                source_id: None,
                source_label: None,
            },
        ]);

        let names = proxies
            .iter()
            .filter_map(|item| item.proxy.get("name").and_then(Value::as_str))
            .collect::<Vec<_>>();
        assert_eq!(names, ["节点", "节点 1"]);
    }

    #[test]
    fn test_proxy_fingerprint_borrows_string_fields_and_formats_scalars() {
        assert!(matches!(
            scalar_text_value(&json!("EDGE.EXAMPLE.COM")),
            Some(Cow::Borrowed("EDGE.EXAMPLE.COM"))
        ));
        assert!(
            matches!(scalar_text_value(&json!(443)), Some(Cow::Owned(value)) if value == "443")
        );
        assert!(
            matches!(scalar_text_value(&json!(true)), Some(Cow::Owned(value)) if value == "true")
        );

        let mut proxy = Map::new();
        proxy.insert("type".into(), json!("SS"));
        proxy.insert("server".into(), json!("EDGE.EXAMPLE.COM"));
        proxy.insert("port".into(), json!(443));
        proxy.insert("uuid".into(), json!(true));
        proxy.insert("password".into(), json!("PASS"));
        proxy.insert("cipher".into(), json!("AES-128-GCM"));
        proxy.insert("sni".into(), json!("CDN.EXAMPLE.COM"));

        assert_eq!(
            proxy_fingerprint(&proxy),
            "ss|edge.example.com|443|true|pass|aes-128-gcm|cdn.example.com"
        );
    }

    #[test]
    fn test_proxy_fingerprint_avoids_intermediate_value_array() {
        let source = include_str!("free_nodes.rs");
        let map_values = concat!("PROXY_FINGERPRINT_KEYS.", "map(|key|");

        assert!(
            !source.contains(map_values),
            "proxy fingerprinting should scan keys directly without an intermediate Option<Cow> array"
        );
    }

    #[test]
    fn test_unique_name_cleans_dirty_names_and_preserves_case_insensitive_suffixes() {
        let mut used_names = HashSet::new();
        let mut next_name_suffixes = HashMap::new();

        assert_eq!(
            unique_name("  Fast\r\nNode  ", &mut used_names, &mut next_name_suffixes,),
            "Fast  Node"
        );
        assert_eq!(
            unique_name("fast  node", &mut used_names, &mut next_name_suffixes),
            "fast  node 1"
        );
        assert_eq!(
            unique_name("   ", &mut used_names, &mut next_name_suffixes),
            "proxy"
        );
        assert_eq!(
            unique_name("\nproxy\r", &mut used_names, &mut next_name_suffixes),
            "proxy 1"
        );
    }

    #[test]
    fn test_unique_name_advances_collision_suffix_without_rescanning_old_suffixes() {
        let mut used_names = HashSet::new();
        let mut next_name_suffixes = HashMap::new();

        assert_eq!(
            unique_name("Node", &mut used_names, &mut next_name_suffixes),
            "Node"
        );
        assert_eq!(
            unique_name("node", &mut used_names, &mut next_name_suffixes),
            "node 1"
        );
        assert_eq!(
            unique_name("NODE", &mut used_names, &mut next_name_suffixes),
            "NODE 2"
        );
        assert_eq!(
            unique_name("node 1", &mut used_names, &mut next_name_suffixes),
            "node 1 1"
        );

        assert_eq!(used_names.len(), 4);
        assert!(used_names.contains("node"));
        assert!(used_names.contains("node 1"));
        assert!(used_names.contains("node 2"));
        assert!(used_names.contains("node 1 1"));
        assert_eq!(next_name_suffixes.get("node"), Some(&3));
    }

    #[test]
    fn test_unique_name_large_duplicate_run_keeps_monotonic_suffixes() {
        let mut used_names = HashSet::new();
        let mut next_name_suffixes = HashMap::new();
        let mut last = String::new();

        for _ in 0..10_000 {
            last = unique_name("same", &mut used_names, &mut next_name_suffixes);
        }

        assert_eq!(last, "same 9999");
        assert_eq!(used_names.len(), 10_000);
        assert_eq!(next_name_suffixes.get("same"), Some(&10_000));
    }

    #[test]
    fn test_unique_name_ascii_fast_path_preserves_non_ascii_names() {
        let mut used_names = HashSet::new();
        let mut next_name_suffixes = HashMap::new();

        assert_eq!(
            unique_name("香港 FAST", &mut used_names, &mut next_name_suffixes),
            "香港 FAST"
        );
        assert_eq!(
            unique_name("香港 fast", &mut used_names, &mut next_name_suffixes),
            "香港 fast 1"
        );

        let mut key = String::new();
        push_ascii_lowercase(&mut key, "节点 FAST🚀");
        assert_eq!(key, "节点 fast🚀");
    }

    #[test]
    fn test_date_label_from_text_supports_compact_date() {
        let token = date_token_from_text("https://example.com/20260614/clash.yaml").unwrap();

        assert_eq!(date_label_from_token(token), "日期 2026-06-14");
    }

    #[test]
    fn test_date_token_from_text_avoids_label_round_trip() {
        assert_eq!(
            date_token("https://example.com/2026-06-14/clash.yaml"),
            20260614
        );
        assert_eq!(date_token("https://example.com/2026_06_15/list"), 20260615);
        assert_eq!(date_token("https://example.com/no-date"), 0);
        assert_eq!(date_token_from_label("2026-06-16"), 20260616);
        assert_eq!(date_token_from_label("2026-06-19T00:00:00Z"), 20260619);
        assert_eq!(
            normalize_date_group_label("2026-06-19T00:00:00Z"),
            "日期 2026-06-19"
        );
    }

    #[test]
    fn test_date_token_rejects_invalid_calendar_dates() {
        assert_eq!(date_token("https://example.com/2026-99-19/clash.yaml"), 0);
        assert_eq!(date_token("https://example.com/2026-02-29/clash.yaml"), 0);
        assert_eq!(
            date_token("https://example.com/2024-02-29/clash.yaml"),
            20240229
        );
        assert_eq!(date_token_from_label("2026-04-31T00:00:00Z"), 0);
    }

    #[test]
    fn test_build_clash_yaml_respects_auto_prefer_switch() {
        let mut proxy = Map::new();
        proxy.insert("name".into(), json!("old"));
        proxy.insert("type".into(), json!("ss"));
        proxy.insert("server".into(), json!("old.example.com"));
        proxy.insert("port".into(), json!(443));
        proxy.insert("cipher".into(), json!("aes"));
        proxy.insert("password".into(), json!("pass"));
        let item = DatedProxy {
            proxy,
            date_label: "2026-06-13".into(),
            date_token: 20260613,
            source_id: None,
            source_label: None,
        };

        let disabled = build_clash_yaml(std::slice::from_ref(&item), 20260614, false).unwrap();
        let enabled = build_clash_yaml(&[item], 20260614, true).unwrap();

        assert!(!disabled.contains(FREE_NODES_TREASURE_GROUP_NAME));
        assert!(disabled.contains("日期 2026-06-13"));
        assert!(!enabled.contains(FREE_NODES_TREASURE_GROUP_NAME));
        assert!(enabled.contains("日期 2026-06-13"));
    }

    #[test]
    fn test_build_clash_yaml_keeps_historical_dates_and_source_groups() {
        let mut old_proxy = Map::new();
        old_proxy.insert("name".into(), json!("old-a"));
        old_proxy.insert("type".into(), json!("ss"));
        old_proxy.insert("server".into(), json!("old-a.example.com"));
        old_proxy.insert("port".into(), json!(443));
        old_proxy.insert("cipher".into(), json!("aes"));
        old_proxy.insert("password".into(), json!("pass"));

        let mut today_proxy = Map::new();
        today_proxy.insert("name".into(), json!("today-b"));
        today_proxy.insert("type".into(), json!("ss"));
        today_proxy.insert("server".into(), json!("today-b.example.com"));
        today_proxy.insert("port".into(), json!(443));
        today_proxy.insert("cipher".into(), json!("aes"));
        today_proxy.insert("password".into(), json!("pass"));

        let yaml = build_clash_yaml(
            &[
                DatedProxy {
                    proxy: old_proxy,
                    date_label: "2026-06-13".into(),
                    date_token: 20260613,
                    source_id: Some("source-a".into()),
                    source_label: Some("Source A".into()),
                },
                DatedProxy {
                    proxy: today_proxy,
                    date_label: "2026-06-14".into(),
                    date_token: 20260614,
                    source_id: Some("source-b".into()),
                    source_label: Some("Source B".into()),
                },
            ],
            20260614,
            true,
        )
        .unwrap();

        assert!(yaml.contains("日期 2026-06-13"));
        assert!(yaml.contains("日期 2026-06-14"));
        assert!(yaml.contains("来源 Source A"));
        assert!(yaml.contains("来源 Source B"));
        assert!(!yaml.contains(FREE_NODES_TREASURE_GROUP_NAME));

        let value = serde_yaml_ng::from_str::<Value>(&yaml).unwrap();
        let groups = value.get("proxy-groups").and_then(Value::as_array).unwrap();
        let source_groups = groups
            .iter()
            .filter_map(Value::as_object)
            .filter(|group| {
                group
                    .get("name")
                    .and_then(Value::as_str)
                    .is_some_and(|name| name.starts_with(FREE_NODES_SOURCE_GROUP_PREFIX))
            })
            .collect::<Vec<_>>();
        assert_eq!(source_groups.len(), 2, "one category per real source");
        assert!(source_groups
            .iter()
            .all(|group| { group.get("hidden").and_then(Value::as_bool) == Some(false) }));
        assert!(groups
            .iter()
            .filter_map(Value::as_object)
            .filter(|group| {
                group
                    .get("name")
                    .and_then(Value::as_str)
                    .is_some_and(|name| {
                        name == FREE_NODES_GROUP_NAME
                            || name == FREE_NODES_TREASURE_GROUP_NAME
                            || date_token_from_label(name) > 0
                    })
            })
            .all(|group| group.get("hidden").and_then(Value::as_bool) == Some(true)));
    }

    #[test]
    fn test_build_clash_yaml_exposes_all_date_groups() {
        let mut old_proxy = Map::new();
        old_proxy.insert("name".into(), json!("old"));
        old_proxy.insert("type".into(), json!("ss"));
        old_proxy.insert("server".into(), json!("old.example.com"));
        old_proxy.insert("port".into(), json!(443));
        old_proxy.insert("cipher".into(), json!("aes"));
        old_proxy.insert("password".into(), json!("pass"));

        let mut today_proxy = Map::new();
        today_proxy.insert("name".into(), json!("today"));
        today_proxy.insert("type".into(), json!("ss"));
        today_proxy.insert("server".into(), json!("today.example.com"));
        today_proxy.insert("port".into(), json!(443));
        today_proxy.insert("cipher".into(), json!("aes"));
        today_proxy.insert("password".into(), json!("pass"));

        let yaml = build_clash_yaml(
            &[
                DatedProxy {
                    proxy: old_proxy,
                    date_label: "2026-06-13".into(),
                    date_token: 20260613,
                    source_id: None,
                    source_label: None,
                },
                DatedProxy {
                    proxy: today_proxy,
                    date_label: "2026-06-14".into(),
                    date_token: 20260614,
                    source_id: None,
                    source_label: None,
                },
            ],
            20260614,
            false,
        )
        .unwrap();

        assert!(yaml.contains("日期 2026-06-14"));
        assert!(yaml.contains("日期 2026-06-13"));
        assert!(yaml.contains("old"));
        assert!(yaml.contains("today"));
    }

    #[test]
    fn test_build_clash_yaml_auto_prefer_keeps_sources_separate_from_date_main_group() {
        let mut source_a_proxy = Map::new();
        source_a_proxy.insert("name".into(), json!("source-a-node"));
        source_a_proxy.insert("type".into(), json!("ss"));
        source_a_proxy.insert("server".into(), json!("a.example.com"));
        source_a_proxy.insert("port".into(), json!(443));
        source_a_proxy.insert("cipher".into(), json!("aes"));
        source_a_proxy.insert("password".into(), json!("pass-a"));

        let mut source_b_proxy = Map::new();
        source_b_proxy.insert("name".into(), json!("source-b-node"));
        source_b_proxy.insert("type".into(), json!("ss"));
        source_b_proxy.insert("server".into(), json!("b.example.com"));
        source_b_proxy.insert("port".into(), json!(443));
        source_b_proxy.insert("cipher".into(), json!("aes"));
        source_b_proxy.insert("password".into(), json!("pass-b"));

        let yaml = build_clash_yaml(
            &[
                DatedProxy {
                    proxy: source_a_proxy,
                    date_label: "2026-06-13".into(),
                    date_token: 20260613,
                    source_id: Some("source-a".into()),
                    source_label: Some("Source A".into()),
                },
                DatedProxy {
                    proxy: source_b_proxy,
                    date_label: "2026-06-14".into(),
                    date_token: 20260614,
                    source_id: Some("source-b".into()),
                    source_label: Some("Source B".into()),
                },
            ],
            20260614,
            true,
        )
        .unwrap();
        let value = serde_yaml_ng::from_str::<Value>(&yaml).unwrap();
        let groups = value.get("proxy-groups").and_then(Value::as_array).unwrap();
        let main_group = groups
            .iter()
            .filter_map(Value::as_object)
            .find(|group| {
                group
                    .get("name")
                    .and_then(Value::as_str)
                    .is_some_and(|name| name == FREE_NODES_GROUP_NAME)
            })
            .unwrap();
        let main_proxies = main_group
            .get("proxies")
            .and_then(Value::as_array)
            .unwrap()
            .iter()
            .filter_map(Value::as_str)
            .collect::<Vec<_>>();

        assert_eq!(main_proxies, vec!["日期 2026-06-14", "日期 2026-06-13"]);
        assert!(groups.iter().filter_map(Value::as_object).any(|group| group
            .get("name")
            .and_then(Value::as_str)
            .is_some_and(|name| name == "来源 Source A")));
        assert!(groups.iter().filter_map(Value::as_object).any(|group| group
            .get("name")
            .and_then(Value::as_str)
            .is_some_and(|name| name == "来源 Source B")));
    }

    #[test]
    fn test_build_clash_yaml_uses_single_pass_group_maps_without_normalize_round_trip() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_clash_yaml")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_urls").next())
            .unwrap();

        assert!(body.contains("date_proxy_names"));
        assert!(body.contains("source_proxy_names"));
        assert!(!body.contains("sorted_labels"));
        assert!(!body.contains("normalize_date_group_label"));
    }

    #[test]
    fn test_build_clash_yaml_preallocates_output_group_vectors() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_clash_yaml")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_urls").next())
            .expect("build_clash_yaml body");

        assert!(
            body.contains(
                "let mut date_proxy_names = HashMap::<i64, Vec<String>>::with_capacity(candidate_count);"
            ),
            "date group output should preallocate to the proxy count upper bound"
        );
        assert!(
            body.contains(
                "let mut source_proxy_names = HashMap::<String, Vec<String>>::with_capacity(candidate_count);"
            ),
            "source group output should preallocate to the proxy count upper bound"
        );
        assert!(
            body.contains("let mut groups = Vec::<Value>::with_capacity("),
            "generated proxy-groups should preallocate to its dynamic upper bound"
        );
        assert!(
            !body.contains("let mut today_proxy_names = Vec::<String>::new();"),
            "today proxy output should not start from an empty Vec"
        );
        assert!(
            !body.contains("let mut treasure_proxy_names = Vec::<String>::new();"),
            "treasure proxy output should not start from an empty Vec"
        );
        assert!(
            !body.contains("let mut groups = Vec::<Value>::new();"),
            "proxy-groups output should not start from an empty Vec"
        );
    }

    #[test]
    fn test_build_clash_yaml_formats_source_group_names_once_per_group() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_clash_yaml")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_urls").next())
            .expect("build_clash_yaml body");
        let global_capacity = body
            .split("let mut global_proxies")
            .nth(1)
            .and_then(|rest| rest.split(");").next())
            .expect("global proxy capacity expression");

        assert!(
            !body.contains(
                "let source_group = format!(\"{FREE_NODES_SOURCE_GROUP_PREFIX}{source_label}\");"
            ),
            "source group names should not be formatted once per proxy"
        );
        assert!(
            body.contains(".entry(source_label.to_string())"),
            "source proxy membership should be keyed by the raw source label"
        );
        assert!(
            body.contains("format!(\"{FREE_NODES_SOURCE_GROUP_PREFIX}{label}\")"),
            "source group names should be formatted while emitting one group"
        );
        assert!(
            global_capacity.contains("usize::from(!treasure_proxy_names.is_empty())"),
            "GLOBAL proxy list capacity should include the optional treasure group"
        );
    }

    #[test]
    fn test_build_clash_yaml_formats_date_group_names_once_per_date() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_clash_yaml")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_urls").next())
            .expect("build_clash_yaml body");

        assert!(
            body.contains(
                "let mut date_proxy_names = HashMap::<i64, Vec<String>>::with_capacity(candidate_count);"
            ),
            "date proxy membership should be keyed by compact date tokens"
        );
        assert!(
            !body.contains("let date_label = date_label_from_token(item.date_token);"),
            "date labels should not be formatted once per proxy"
        );
        assert!(
            body.contains("date_label_from_token(*token)"),
            "date labels should be formatted while emitting one date group"
        );
    }

    #[test]
    fn test_build_clash_yaml_streams_group_labels_without_collecting_label_vecs() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_clash_yaml")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_urls").next())
            .expect("build_clash_yaml body");

        assert!(
            !body.contains("let date_group_labels ="),
            "date group labels should be streamed from sorted tokens instead of collected into a temporary Vec"
        );
        assert!(
            !body.contains("let source_group_labels ="),
            "source group labels should be streamed from sorted labels instead of collected into a temporary Vec"
        );
    }

    #[test]
    fn test_discover_urls_preallocates_github_api_results_after_discovery() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn discover_urls")
            .nth(1)
            .and_then(|rest| rest.split("fn add_contextual_discovered_urls").next())
            .expect("discover_urls body");

        assert!(
            body.contains("Vec::<String>::with_capacity(urls.len())"),
            "GitHub API discovery branch should preallocate result to the exact discovered URL count"
        );
        assert!(
            body.contains("DiscoveredUrlIndex::with_capacity(urls.len())"),
            "GitHub API discovery branch should preallocate the dedup index to the exact discovered URL count"
        );
        assert!(
            !body
                .split("if let Some(urls) = discover_github_api_urls")
                .next()
                .unwrap_or_default()
                .contains("Vec::<String>::new()"),
            "discover_urls should not allocate an empty result before the GitHub API count is known"
        );
    }

    #[test]
    fn test_discover_urls_preallocates_plain_page_results() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn discover_urls")
            .nth(1)
            .and_then(|rest| rest.split("fn add_contextual_discovered_urls").next())
            .expect("discover_urls body");
        let plain_branch = body
            .split("return result;")
            .nth(1)
            .expect("plain discovery branch");

        assert!(
            plain_branch.contains("Vec::<String>::with_capacity(DISCOVERY_URL_INITIAL_CAPACITY)"),
            "plain page discovery should preallocate discovered URL storage"
        );
        assert!(
            plain_branch
                .contains("DiscoveredUrlIndex::with_capacity(DISCOVERY_URL_INITIAL_CAPACITY)"),
            "plain page discovery should preallocate the dedup index"
        );
        assert!(
            !plain_branch.contains("Vec::<String>::new()")
                && !plain_branch.contains("DiscoveredUrlIndex::default()"),
            "plain page discovery should not start from empty URL storage"
        );
    }

    #[test]
    fn test_discovered_url_index_with_capacity_preallocates_buckets() {
        let index = DiscoveredUrlIndex::with_capacity(64);

        assert!(index.capacity() >= 64);
    }

    #[test]
    fn test_extract_existing_dated_proxies_uses_compact_group_markers() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn extract_existing_dated_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn should_keep_existing_proxy").next())
            .unwrap();

        assert!(body
            .contains("HashMap::<String, ExistingProxyGroup>::with_capacity(raw_proxies.len())"));
        assert!(body.contains("HashMap::<String, String>::with_capacity(raw_proxies.len())"));
        assert!(!body.contains("treasure_names"));
        assert!(!body.contains("group_name.clone()"));
    }

    #[test]
    fn test_extract_existing_dated_proxies_preallocates_index_and_output() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn extract_existing_dated_proxies")
            .nth(1)
            .and_then(|rest| rest.split("fn should_keep_existing_proxy").next())
            .unwrap();

        assert!(body
            .contains("HashMap::<String, ExistingProxyGroup>::with_capacity(raw_proxies.len())"));
        assert!(body.contains("Vec::<DatedProxy>::with_capacity(raw_proxies.len())"));
        assert!(!body.contains(".collect()"));
    }

    #[test]
    fn test_merge_fresh_and_existing_dated_proxies_keeps_unexpired_history() {
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 10000,
                sources: vec![],
            },
            enabled_source_ids: vec![],
            source_ids: None,
            existing_config_text: Some(
                r#"
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
  - name: stale-node
    type: ss
    server: stale.example.com
    port: 443
    cipher: aes-128-gcm
    password: stale-pass
proxy-groups:
  - name: "日期 2026-05-30"
    type: url-test
    proxies:
      - old-node
  - name: "日期 2025-01-01"
    type: url-test
    proxies:
      - stale-node
"#
                .to_string(),
            ),
            preference: PreferenceInput {
                fetch_concurrency: 8,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: days_from_civil(2026, 6, 19),
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let mut fresh_proxy = Map::new();
        fresh_proxy.insert("name".into(), json!("fresh-node"));
        fresh_proxy.insert("type".into(), json!("ss"));
        fresh_proxy.insert("server".into(), json!("fresh.example.com"));
        fresh_proxy.insert("port".into(), json!(443));
        fresh_proxy.insert("cipher".into(), json!("aes-128-gcm"));
        fresh_proxy.insert("password".into(), json!("fresh-pass"));

        let merged = merge_fresh_and_existing_dated_proxies(
            &input,
            vec![DatedProxy {
                proxy: fresh_proxy,
                date_label: "日期 2026-06-19".into(),
                date_token: 20260619,
                source_id: Some("fresh".into()),
                source_label: Some("Fresh".into()),
            }],
        );
        let yaml = build_clash_yaml(&deduplicate_and_name(merged), 20260619, false).unwrap();

        assert!(yaml.contains("fresh-node"));
        assert!(yaml.contains("old-node"));
        assert!(!yaml.contains("stale-node"));
        assert!(yaml.contains("日期 2026-06-19"));
        assert!(yaml.contains("日期 2026-05-30"));
        assert!(!yaml.contains("日期 2025-01-01"));
    }

    #[test]
    fn test_prefer_free_nodes_config_keeps_old_date_group_switchable() {
        let input = PreferConfigInput {
            config_text: r#"
proxies:
  - name: old-node
    type: ss
    server: old.example.com
    port: 443
    cipher: aes-128-gcm
    password: old-pass
proxy-groups:
  - name: "2026-05-30"
    type: url-test
    proxies:
      - old-node
"#
            .to_string(),
            history_timeout_hours: 10000,
            now_day_number: days_from_civil(2026, 6, 19),
            today_token: 20260619,
            delete_expired_groups: false,
        };

        let output = prefer_free_nodes_config(input).unwrap();

        assert_eq!(output.before_count, 1);
        assert_eq!(output.after_count, 1);
        assert_eq!(output.removed_count, 0);
        assert!(output.yaml.contains("日期 2026-05-30"));
        assert!(!output.yaml.contains(FREE_NODES_TREASURE_GROUP_NAME));
        assert!(output.yaml.contains("old-node"));
    }

    #[test]
    fn test_prefer_free_nodes_config_rejects_empty_result_before_write() {
        let input = PreferConfigInput {
            config_text: "proxy-groups: []".to_string(),
            history_timeout_hours: 10000,
            now_day_number: days_from_civil(2026, 6, 19),
            today_token: 20260619,
            delete_expired_groups: false,
        };

        let err = prefer_free_nodes_config(input).unwrap_err();

        assert!(err.contains("已保留原配置"));
    }

    #[test]
    fn test_summarize_free_node_stability_levels() {
        let good = summarize_free_node_stability(StabilitySampleInput {
            proxy_name: "node-good".into(),
            delays: vec![100, 110, 105],
            failures: 0,
        });
        let poor = summarize_free_node_stability(StabilitySampleInput {
            proxy_name: "node-poor".into(),
            delays: vec![100],
            failures: 2,
        });

        assert_eq!(good.average_delay, Some(105));
        assert_eq!(good.level, "good");
        assert_eq!(poor.level, "poor");
    }

    #[test]
    fn test_summarize_free_node_stability_ignores_single_latency_spike() {
        let result = summarize_free_node_stability(StabilitySampleInput {
            proxy_name: "node-spike".into(),
            delays: vec![100, 110, 900],
            failures: 0,
        });

        assert_eq!(result.average_delay, Some(105));
        assert_eq!(result.level, "good");
    }

    #[test]
    fn test_fetch_merge_free_nodes_preallocates_fetch_times_map() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn fetch_merge_free_nodes(input")
            .nth(1)
            .and_then(|rest| rest.split("fn prefer_free_nodes_config").next())
            .expect("fetch_merge_free_nodes body");

        assert!(body.contains("HashMap::with_capacity(status_list.len())"));
        assert!(
            !body.contains(".map(|status| (status.source_id.clone(), status.fetched_at.clone()))")
        );
    }

    #[test]
    fn test_free_nodes_fetch_concurrency_is_bounded_by_candidate_count() {
        assert_eq!(normalized_free_nodes_fetch_concurrency(128, 0), 0);
        assert_eq!(normalized_free_nodes_fetch_concurrency(0, 10), 1);
        assert_eq!(normalized_free_nodes_fetch_concurrency(512, 10), 10);
        assert_eq!(normalized_free_nodes_fetch_concurrency(16, 4), 4);
        assert_eq!(normalized_free_nodes_fetch_concurrency(4, 10), 4);
    }

    #[test]
    fn test_fetch_merge_free_nodes_skips_shared_queue_when_no_workers() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn fetch_merge_free_nodes(input")
            .nth(1)
            .and_then(|rest| {
                rest.split("fn normalized_free_nodes_fetch_concurrency")
                    .next()
            })
            .expect("fetch_merge_free_nodes body");
        let threaded_branch_start = body
            .find("let mut handles = Vec::with_capacity(concurrency);")
            .expect("threaded branch");
        let threaded_body = &body[threaded_branch_start..];
        let guard_index = threaded_body
            .find("if concurrency > 0")
            .expect("concurrency guard");
        let queue_index = threaded_body
            .find("shared_fetch_queue(candidates)")
            .expect("threaded queue creation");

        assert!(
            guard_index < queue_index,
            "threaded shared fetch queue should only be initialized when workers exist"
        );
    }

    #[test]
    fn test_fetch_merge_free_nodes_preallocates_worker_result_buffers() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn fetch_merge_free_nodes(input")
            .nth(1)
            .and_then(|rest| {
                rest.split("fn normalized_free_nodes_fetch_concurrency")
                    .next()
            })
            .expect("fetch_merge_free_nodes body");

        assert!(
            body.contains("let worker_result_capacity = candidate_count.div_ceil(concurrency);"),
            "worker result buffers should be sized from the candidate/concurrency ratio"
        );
        assert!(
            body.contains("Vec::<DatedProxy>::with_capacity(worker_result_capacity)"),
            "worker local proxy results should preallocate to the expected per-worker candidate count"
        );
        assert!(
            body.contains("Vec::<SourceStatus>::with_capacity(worker_result_capacity)"),
            "worker local statuses should preallocate to the expected per-worker candidate count"
        );
        assert!(
            body.contains("Vec::<DatedProxy>::with_capacity(candidate_count)"),
            "merged fresh proxy collection should preallocate to at least the candidate count"
        );
        assert!(
            body.contains("Vec::<SourceStatus>::with_capacity(candidate_count)"),
            "merged status collection should preallocate to the candidate count"
        );
        assert!(
            !body.contains("let mut local_proxies = Vec::<DatedProxy>::new();"),
            "worker local proxies should not start from an empty Vec"
        );
        assert!(
            !body.contains("let mut local_statuses = Vec::<SourceStatus>::new();"),
            "worker local statuses should not start from an empty Vec"
        );
    }

    #[test]
    fn test_resolve_candidates_short_circuits_empty_source_filters() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn resolve_candidates(input")
            .nth(1)
            .and_then(|rest| rest.split("fn build_config_candidates").next())
            .expect("resolve_candidates body");
        let enabled_guard_index = body
            .find("input.enabled_source_ids.is_empty()")
            .expect("enabled source guard");
        let target_guard_index = body
            .find("input.source_ids.as_ref().is_some_and(Vec::is_empty)")
            .expect("target source guard");
        let enabled_set_index = body
            .find("let mut enabled = HashSet::with_capacity")
            .expect("enabled set construction");

        assert!(enabled_guard_index < enabled_set_index);
        assert!(target_guard_index < enabled_set_index);
    }

    #[test]
    fn test_resolve_candidates_preallocates_source_filter_sets_without_collect() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn resolve_candidates(input")
            .nth(1)
            .and_then(|rest| rest.split("fn build_config_candidates").next())
            .expect("resolve_candidates body");

        assert!(
            body.contains("HashSet::with_capacity(input.enabled_source_ids.len())"),
            "enabled source filter set should be preallocated from enabled_source_ids"
        );
        assert!(
            body.contains("HashSet::with_capacity(ids.len())"),
            "target source filter set should be preallocated from source_ids"
        );
        assert!(
            !body.contains(".collect();"),
            "source filter sets should be filled directly instead of collecting iterators"
        );
    }

    #[test]
    fn test_resolve_candidates_preallocates_initial_candidate_collections() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn resolve_candidates(input")
            .nth(1)
            .and_then(|rest| rest.split("fn build_config_candidates").next())
            .expect("resolve_candidates body");

        assert!(
            body.contains("let initial_candidate_capacity")
                && body.contains("resolve_candidate_initial_capacity("),
            "resolve_candidates should estimate initial candidate container capacity once"
        );
        assert!(
            body.contains(
                "HashMap::<String, Arc<CandidateSource>>::with_capacity(initial_candidate_capacity)"
            ),
            "config candidate map should not grow from an empty HashMap"
        );
        assert!(
            body.contains("VecDeque::<ConfigCandidate>::with_capacity(initial_candidate_capacity)"),
            "page discovery queue should be preallocated from the same selected source estimate"
        );
        assert!(
            body.contains("HashSet::<String>::with_capacity(initial_candidate_capacity)"),
            "page URL and fetch-key dedup sets should be preallocated"
        );
        assert!(!body
            .contains("let mut configs: HashMap<String, Arc<CandidateSource>> = HashMap::new();"));
    }

    #[test]
    fn test_resolve_candidate_initial_capacity_counts_selected_sources_without_url_allocation() {
        let selected = SourceInput {
            id: "selected".into(),
            label: "Selected".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: true,
            raw_candidates: vec![
                "https://selected.example.com/raw-a.yaml".into(),
                "https://selected.example.com/raw-b.yaml".into(),
            ],
            candidate_urls: vec!["https://selected.example.com/candidate.yaml".into()],
        };
        let disabled = SourceInput {
            id: "disabled".into(),
            label: "Disabled".into(),
            seed: "https://disabled.example.com/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: true,
            raw_candidates: vec!["https://disabled.example.com/raw.yaml".into()],
            candidate_urls: vec!["https://disabled.example.com/candidate.yaml".into()],
        };
        let mut enabled = HashSet::with_capacity(1);
        enabled.insert("selected");
        let mut targets = HashSet::with_capacity(1);
        targets.insert("selected");

        let capacity =
            resolve_candidate_initial_capacity(&[selected, disabled], &enabled, Some(&targets));

        assert_eq!(
            capacity,
            1 + 1 + 2 + GITHUB_DISCOVERY_INITIAL_CANDIDATE_ESTIMATE
        );
    }

    #[test]
    fn test_agent_cache_reuses_same_timeout_agent() {
        let mut cache = AgentCache::default();

        cache.get(10, None).unwrap();
        cache.get(10, None).unwrap();
        cache.get(20, None).unwrap();

        assert_eq!(cache.len(), 2);
    }

    #[test]
    fn test_canonical_fetch_key_groups_github_raw_and_mirror_urls() {
        let raw = "https://raw.githubusercontent.com/owner/repo/main/clash.yaml";
        let mirror =
            "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml";

        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(mirror));
    }

    #[test]
    fn test_canonical_fetch_key_groups_ghfile_github_blob_mirror_and_raw() {
        let raw = "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml";
        let mirror_blob =
            "https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml";

        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(mirror_blob));
    }

    #[test]
    fn test_canonical_fetch_key_groups_github_raw_page_and_blob_refs_heads_with_raw() {
        let raw = "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml";
        let github_raw_page = "https://github.com/PuddinCat/BestClash/raw/main/proxies.yaml";
        let github_blob_refs =
            "https://github.com/PuddinCat/BestClash/blob/refs/heads/main/proxies.yaml";

        assert_eq!(
            canonical_fetch_key(raw),
            canonical_fetch_key(github_raw_page)
        );
        assert_eq!(
            canonical_fetch_key(raw),
            canonical_fetch_key(github_blob_refs)
        );
    }

    #[test]
    fn test_canonical_fetch_key_strips_github_mirror_prefix_case_insensitively() {
        let raw = "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml";
        let mirror_blob =
            "HTTPS://GHFILE.GEEKERTAO.TOP/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml";

        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(mirror_blob));
    }

    #[test]
    fn test_strip_known_github_mirror_prefix_reuses_url_bytes() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn strip_known_github_mirror_prefix")
            .nth(1)
            .and_then(|rest| rest.split("fn github_file_page_to_raw").next())
            .expect("strip_known_github_mirror_prefix body");

        assert!(
            body.matches("url.as_bytes()").count() == 1,
            "GitHub mirror prefix stripping should cache url.as_bytes outside the prefix loop"
        );
        assert!(
            !body.contains("find_map(|prefix| {\n        let bytes = url.as_bytes();"),
            "GitHub mirror prefix stripping should not recompute bytes for every prefix"
        );
    }

    #[test]
    fn test_canonical_fetch_key_groups_raw_refs_heads_with_branch_short_path() {
        let short = "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml";
        let refs =
            "https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml";

        assert_eq!(canonical_fetch_key(short), canonical_fetch_key(refs));
    }

    #[test]
    fn test_canonical_fetch_key_groups_jsdelivr_github_mirror_with_raw() {
        let raw = "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml";
        let cdn = "https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml";
        let fastly = "https://fastly.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml";
        let gcore = "https://gcore.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml";

        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(cdn));
        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(fastly));
        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(gcore));
    }

    #[test]
    fn test_canonical_fetch_key_groups_rawgithubusercontent_mirror_with_raw() {
        let raw = "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml";
        let mirror = "https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml";

        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(mirror));
    }

    #[test]
    fn test_canonical_fetch_key_groups_github_contents_default_ref() {
        let contents = "https://api.github.com/repos/owner/repo/contents";
        let main = "https://api.github.com/repos/owner/repo/contents?ref=main";

        assert_eq!(canonical_fetch_key(contents), canonical_fetch_key(main));
    }

    #[test]
    fn test_canonical_fetch_key_groups_github_contents_subdir_default_ref() {
        let contents = "https://api.github.com/repos/owner/repo/contents/configs";
        let main = "https://api.github.com/repos/owner/repo/contents/configs?ref=main";

        assert_eq!(canonical_fetch_key(contents), canonical_fetch_key(main));
    }

    #[test]
    fn test_page_fetch_key_deduplicates_github_contents_default_ref() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut visited_page_fetch_keys = HashSet::<String>::new();
        let contents = ConfigCandidate::from_candidate_source_ref(
            "https://api.github.com/repos/owner/repo/contents".into(),
            &source,
        );
        let main_contents = ConfigCandidate::from_candidate_source_ref(
            "https://api.github.com/repos/owner/repo/contents?ref=main".into(),
            &source,
        );

        assert!(visited_page_fetch_keys.insert(contents.fetch_key));
        assert!(!visited_page_fetch_keys.insert(main_contents.fetch_key));
    }

    #[test]
    fn test_page_fetch_key_deduplicates_github_contents_subdir_default_ref() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut visited_page_fetch_keys = HashSet::<String>::new();
        let contents = ConfigCandidate::from_candidate_source_ref(
            "https://api.github.com/repos/owner/repo/contents/configs".into(),
            &source,
        );
        let main_contents = ConfigCandidate::from_candidate_source_ref(
            "https://api.github.com/repos/owner/repo/contents/configs?ref=main".into(),
            &source,
        );

        assert!(visited_page_fetch_keys.insert(contents.fetch_key));
        assert!(!visited_page_fetch_keys.insert(main_contents.fetch_key));
    }

    #[test]
    fn test_normalize_url_keeps_common_url_fast_path_behaviors() {
        assert_eq!(
            normalize_url(" https://example.com/sub.yaml?token=a&amp;target=clash); "),
            "https://example.com/sub.yaml?token=a&target=clash"
        );
        assert_eq!(
            normalize_url("//example.com/sub.yaml"),
            "https://example.com/sub.yaml"
        );
        assert_eq!(
            normalize_url("https://github.com/owner/repo/blob/main/subs/clash.yaml"),
            "https://raw.githubusercontent.com/owner/repo/main/subs/clash.yaml"
        );
    }

    #[test]
    fn test_normalize_url_prefilters_github_blob_parse_for_plain_urls() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn normalize_url")
            .and_then(|(_, rest)| rest.split_once("fn canonical_fetch_key"))
            .map(|(body, _)| body)
            .expect("normalize_url body");
        let hint_index = body
            .find("contains_ascii_case_insensitive(&value, \"github.com\")")
            .expect("github host hint");
        let file_page_index = body
            .find("github_file_page_to_raw(&value)")
            .expect("file page parser");

        assert!(hint_index < file_page_index);
        assert_eq!(
            normalize_url(" https://example.com/sub.yaml?token=a&amp;target=clash); "),
            "https://example.com/sub.yaml?token=a&target=clash"
        );
        assert_eq!(
            normalize_url("https://github.com/owner/repo/blob/main/subs/clash.yaml"),
            "https://raw.githubusercontent.com/owner/repo/main/subs/clash.yaml"
        );
    }

    #[test]
    fn test_canonical_fetch_key_prefilters_plain_urls_before_github_parsers() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn canonical_fetch_key")
            .and_then(|(_, rest)| rest.split_once("fn strip_known_github_mirror_prefix"))
            .map(|(body, _)| body)
            .expect("canonical_fetch_key body");
        let hint_index = body
            .find("has_github_fetch_key_canonical_hint(&value)")
            .expect("canonical hint prefilter");
        let parser_index = body
            .find("github_path_mirror_to_raw(&value)")
            .expect("GitHub path mirror parser");

        assert!(hint_index < parser_index);
        assert_eq!(
            canonical_fetch_key(" https://example.com/sub.yaml?target=clash); "),
            "https://example.com/sub.yaml?target=clash"
        );
        assert_eq!(
            canonical_fetch_key("https://github.com/owner/repo/blob/main/subs/clash.yaml"),
            "https://raw.githubusercontent.com/owner/repo/main/subs/clash.yaml"
        );
        assert_eq!(
            canonical_fetch_key("https://cdn.jsdelivr.net/gh/owner/repo@main/subs/clash.yaml"),
            "https://raw.githubusercontent.com/owner/repo/main/subs/clash.yaml"
        );
    }

    #[test]
    fn test_github_fetch_key_canonical_hint_covers_raw_api_blob_and_jsdelivr() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn has_github_fetch_key_canonical_hint")
            .and_then(|(_, rest)| rest.split_once("fn strip_known_github_mirror_prefix"))
            .map(|(body, _)| body)
            .expect("has_github_fetch_key_canonical_hint body");

        assert!(!body.contains("contains_any_ascii_case_insensitive"));
        assert!(has_github_fetch_key_canonical_hint(
            "https://raw.githubusercontent.com/owner/repo/main/sub.yaml"
        ));
        assert!(has_github_fetch_key_canonical_hint(
            "https://api.github.com/repos/owner/repo/contents"
        ));
        assert!(has_github_fetch_key_canonical_hint(
            "https://github.com/owner/repo/blob/main/sub.yaml"
        ));
        assert!(has_github_fetch_key_canonical_hint(
            "https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/sub.yaml"
        ));
        assert!(has_github_fetch_key_canonical_hint(
            "https://cdn.jsdelivr.net/gh/owner/repo@main/sub.yaml"
        ));
        assert!(has_github_fetch_key_canonical_hint(
            "https://fastly.jsdelivr.net/gh/owner/repo@main/sub.yaml"
        ));
        assert!(!has_github_fetch_key_canonical_hint(
            "https://example.com/sub.yaml"
        ));
    }

    #[test]
    fn test_github_file_page_to_raw_avoids_collecting_path_segments() {
        let source = include_str!("free_nodes.rs");
        let collect_segments = concat!("parsed.path_segments()?.", "collect()");
        let join_segments = concat!("segments[4..].", "join(\"/\")");

        assert!(
            !source.contains(collect_segments),
            "github blob normalization should stream path segments without a temporary Vec"
        );
        assert!(
            !source.contains(join_segments),
            "github blob normalization should write the remaining path directly"
        );
    }

    #[test]
    fn test_github_raw_refs_heads_to_branch_avoids_collecting_path_segments() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn github_raw_refs_heads_to_branch")
            .nth(1)
            .and_then(|rest| rest.split("fn github_discovery_candidates").next())
            .expect("github_raw_refs_heads_to_branch body");

        assert!(
            !body.contains(".collect()"),
            "raw refs/heads normalization should stream path segments without a temporary Vec"
        );
        assert!(
            !body.contains(".join(\"/\")"),
            "raw refs/heads normalization should write the remaining path directly"
        );
    }

    #[test]
    fn test_config_candidate_precomputes_fetch_key() {
        let source = SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let mirror =
            "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml";

        let candidate = ConfigCandidate::from_source_ref(mirror.into(), &source);

        assert_eq!(
            candidate.fetch_key,
            "https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
        );
    }

    #[test]
    fn test_config_candidate_precomputes_sort_date_token() {
        let source = SourceInput {
            id: "dated".into(),
            label: "Dated".into(),
            seed: "https://dated.example.com/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };

        let candidate = ConfigCandidate::from_source_ref(
            "https://dated.example.com/20260619/clash.yaml".into(),
            &source,
        );

        assert_eq!(candidate.date_token, 20260619);
    }

    #[test]
    fn test_config_candidate_date_token_uses_compact_type() {
        let source = include_str!("free_nodes.rs");
        let candidate_body = source
            .split("struct ConfigCandidate {")
            .nth(1)
            .and_then(|rest| rest.split('}').next())
            .expect("ConfigCandidate body");
        let dated_proxy_body = source
            .split("struct DatedProxy {")
            .nth(1)
            .and_then(|rest| rest.split('}').next())
            .expect("DatedProxy body");

        assert!(
            candidate_body.contains("date_token: i32"),
            "ConfigCandidate only sorts yyyyMMdd/0 tokens and should keep the field compact"
        );
        assert!(
            dated_proxy_body.contains("date_token: i64"),
            "DatedProxy keeps the wider token type for existing date grouping code"
        );
    }

    #[test]
    fn test_build_config_candidates_reuses_precomputed_primary_fields() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains("push_unique_config_candidate_from_candidate("),
            "primary candidates should reuse precomputed fetch_key/date_token fields"
        );
        assert!(
            !body.contains("preferred_fetch_url(candidate)"),
            "primary candidates should not be rebuilt through a URL-only path that recomputes canonical fields"
        );
    }

    #[test]
    fn test_build_config_candidates_reuses_precomputed_github_fallback_fields() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            !body.contains("push_unique_config_candidate("),
            "GitHub fallback candidates should reuse precomputed fields instead of recomputing from each mirror URL"
        );
        assert!(
            body.matches("push_unique_config_candidate_from_candidate(")
                .count()
                >= 5,
            "primary, path, raw-path, raw mirror, and canonical GitHub candidates should use the precomputed candidate path"
        );
    }

    #[test]
    fn test_config_candidate_uses_lightweight_source_metadata() {
        assert!(std::mem::size_of::<CandidateSource>() < std::mem::size_of::<SourceInput>());

        let source = SourceInput {
            id: "heavy".into(),
            label: "Heavy".into(),
            seed: "https://heavy.example.com/".into(),
            rank: 7,
            update_interval_hours: 6,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec!["https://heavy.example.com/raw.yaml".into()],
            candidate_urls: vec!["https://heavy.example.com/candidate.yaml".into()],
        };

        let candidate = ConfigCandidate::from_source_ref(
            "https://heavy.example.com/config.yaml".into(),
            &source,
        );

        assert_eq!(candidate.source.id, source.id);
        assert_eq!(candidate.source.label, source.label);
        assert_eq!(candidate.source.seed, source.seed);
        assert_eq!(candidate.source.rank, source.rank);
        assert_eq!(
            candidate.source.update_interval_hours,
            source.update_interval_hours
        );
        assert_eq!(candidate.source.page_discovery, source.page_discovery);
    }

    #[test]
    fn test_config_candidates_share_source_metadata_for_same_source() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "shared".into(),
            label: "Shared".into(),
            seed: "https://shared.example.com/".into(),
            rank: 3,
            update_interval_hours: 12,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));

        let first = ConfigCandidate::from_candidate_source_ref(
            "https://shared.example.com/a.yaml".into(),
            &source,
        );
        let second = ConfigCandidate::from_candidate_source_ref(
            "https://shared.example.com/b.yaml".into(),
            &source,
        );

        assert!(Arc::ptr_eq(&first.source, &second.source));
    }

    #[test]
    fn test_github_mirror_urls_expands_raw_to_multiple_equivalent_mirrors() {
        let raw = "https://raw.githubusercontent.com/owner/repo/main/clash.yaml";

        let mirrors = github_mirror_urls(raw);

        assert!(mirrors.len() >= 3);
        for mirror in mirrors {
            assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(&mirror));
        }
    }

    #[test]
    fn test_github_raw_mirror_prefixes_prioritize_domestic_fast_paths() {
        assert_eq!(
            &GITHUB_RAW_MIRROR_PREFIXES[..4],
            [
                "https://gh.llkk.cc/",
                "https://ghfast.top/",
                "https://ghproxy.net/",
                "https://gh-proxy.com/",
            ]
        );
    }

    #[test]
    fn test_nth_github_path_mirror_url_normalizes_raw_refs_heads_branch() {
        let raw =
            "https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml";

        assert_eq!(
            nth_github_path_mirror_url(raw, 0).as_deref(),
            Some("https://gcore.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml")
        );
        assert_eq!(
            nth_github_path_mirror_url(raw, 1).as_deref(),
            Some("https://fastly.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml")
        );
        assert_eq!(
            nth_github_path_mirror_url(raw, 2).as_deref(),
            Some("https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml")
        );
        assert!(
            github_mirror_urls(raw)
                .iter()
                .all(|url| !url.contains("BestClash@refs/heads/main")),
            "path mirrors should not encode refs/heads as the branch name"
        );
    }

    #[test]
    fn test_nth_github_raw_path_mirror_url_normalizes_raw_refs_heads_branch() {
        let raw =
            "https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml";

        assert_eq!(
            nth_github_raw_path_mirror_url(raw, 0).as_deref(),
            Some("https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml")
        );
        assert!(
            github_mirror_urls(raw).iter().any(|url| url
                == "https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml"),
            "raw path mirror should be available as an extra GitHub raw fallback"
        );
    }

    #[test]
    fn test_github_mirror_urls_accepts_mixed_case_hosts_without_normalizing_copy() {
        let raw = "HTTPS://RAW.GITHUBUSERCONTENT.COM/owner/repo/main/clash.yaml";

        let mirrors = github_mirror_urls(raw);

        assert!(mirrors.len() >= 3);
        assert!(mirrors
            .iter()
            .any(|url| starts_with_ascii_case_insensitive(url, "https://gh.llkk.cc/")));
    }

    #[test]
    fn test_github_mirrorable_url_prefilters_before_url_parse() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn is_github_mirrorable_url(url: &str) -> bool {")
            .and_then(|(_, rest)| {
                rest.split_once("#[cfg(test)]\nfn github_mirror_urls")
                    .or_else(|| rest.split_once("#[cfg(test)]\r\nfn github_mirror_urls"))
            })
            .map(|(body, _)| body)
            .expect("is_github_mirrorable_url body");
        let hint_index = body
            .find("has_github_mirrorable_host_hint(url)")
            .expect("github mirrorable host prefilter");
        let parse_index = body.find("Url::parse(url)").expect("url parse");

        assert!(hint_index < parse_index);
        assert!(!is_github_mirrorable_url(
            "https://example.com/proxies.yaml"
        ));
        assert!(is_github_mirrorable_url(
            "https://api.github.com/repos/owner/repo/contents/proxies.yaml"
        ));
    }

    #[test]
    fn test_github_mirrorable_host_hint_avoids_generic_contains_any_scan() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn has_github_mirrorable_host_hint")
            .and_then(|(_, rest)| rest.split_once("fn is_github_mirrorable_url"))
            .map(|(body, _)| body)
            .expect("has_github_mirrorable_host_hint body");

        assert!(!body.contains("contains_any_ascii_case_insensitive"));
        assert!(has_github_mirrorable_host_hint(
            "https://raw.githubusercontent.com/owner/repo/main/proxies.yaml"
        ));
        assert!(has_github_mirrorable_host_hint(
            "https://api.github.com/repos/owner/repo/contents/proxies.yaml"
        ));
        assert!(!has_github_mirrorable_host_hint(
            "https://github.com/owner/repo/blob/main/proxies.yaml"
        ));
        assert!(!has_github_mirrorable_host_hint(
            "https://example.com/proxies.yaml"
        ));
    }

    #[test]
    fn test_first_github_mirror_url_matches_canonical_fetch_key() {
        let raw = "https://raw.githubusercontent.com/owner/repo/main/clash.yaml";

        let mirror = first_github_mirror_url(raw).expect("first mirror");

        assert!(mirror.starts_with("https://gh.llkk.cc/"));
        assert_eq!(canonical_fetch_key(raw), canonical_fetch_key(&mirror));
    }

    #[test]
    fn test_github_raw_seed_candidates_include_main_and_master_branches() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/clash.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/master/clash.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/mihomo.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/clash-meta.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/all.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/base64.txt"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/v2ray.txt"));
        for path in ["free.yaml", "free.yml", "free.txt"] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        for path in ["index.yaml", "index.yml", "index.txt"] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        for path in [
            "clash.txt",
            "config.txt",
            "all.txt",
            "merged.txt",
            "mihomo.txt",
        ] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        for path in [
            "clash-meta.yml",
            "clash-meta.txt",
            "clashmeta.yml",
            "clashmeta.txt",
        ] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        for path in ["meta.yaml", "meta.yml", "meta.txt"] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sub"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sub.yml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sub_en"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sub_zh"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sub_ar"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/v2ray"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/base64"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/list"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/subscribe"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/subscribe.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/subscribe.yml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/subscription"));
        assert!(candidates.iter().any(
            |url| url == "https://raw.githubusercontent.com/owner/repo/main/subscription.yaml"
        ));
        assert!(
            candidates
                .iter()
                .any(|url| url
                    == "https://raw.githubusercontent.com/owner/repo/main/subscription.yml")
        );
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/subscriptions"));
        assert!(candidates.iter().any(
            |url| url == "https://raw.githubusercontent.com/owner/repo/main/subscriptions.yaml"
        ));
        assert!(candidates.iter().any(
            |url| url == "https://raw.githubusercontent.com/owner/repo/main/subscriptions.yml"
        ));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/subscribe.txt"));
        assert!(
            candidates
                .iter()
                .any(|url| url
                    == "https://raw.githubusercontent.com/owner/repo/main/subscription.txt")
        );
        assert!(candidates.iter().any(
            |url| url == "https://raw.githubusercontent.com/owner/repo/main/subscriptions.txt"
        ));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/nodes.txt"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/nodes"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/node"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/node.txt"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/node.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/node.yml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/proxy.txt"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/proxy"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/proxies.txt"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/proxies"));
        for path in ["list.txt", "links.txt", "urls.txt"] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        for path in [
            "profile",
            "profile.txt",
            "profile.yaml",
            "profile.yml",
            "profiles",
            "profiles.txt",
            "profiles.yaml",
            "profiles.yml",
        ] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        assert!(candidates.iter().any(|url| {
            url == "https://raw.githubusercontent.com/owner/repo/main/source/clash-meta.yaml"
        }));
        for path in [
            "node/clash.yaml",
            "node/clash.yml",
            "node/proxies.yaml",
            "node/proxies.yml",
            "node/mihomo.yaml",
            "node/base64.txt",
            "node/sub.txt",
            "node/v2ray.txt",
            "proxy/clash.yaml",
            "proxy/clash.yml",
            "proxy/proxies.yaml",
            "proxy/proxies.yml",
            "proxy/mihomo.yaml",
            "proxy/base64.txt",
            "proxy/sub.txt",
            "proxy/v2ray.txt",
            "proxies/clash.yaml",
            "proxies/clash.yml",
            "proxies/proxies.yaml",
            "proxies/proxies.yml",
            "proxies/mihomo.yaml",
            "proxies/base64.txt",
            "proxies/sub.txt",
            "proxies/v2ray.txt",
        ] {
            let expected = format!("https://raw.githubusercontent.com/owner/repo/main/{path}");
            assert!(candidates.iter().any(|url| url == &expected), "{expected}");
        }
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sub/clash.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sub/base64.txt"));
        assert!(candidates
            .iter()
            .any(|url| url
                == "https://raw.githubusercontent.com/owner/repo/main/subscribe/v2ray.txt"));
        assert!(candidates.iter().any(
            |url| url == "https://raw.githubusercontent.com/owner/repo/main/clash/proxies.yaml"
        ));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/mihomo/all.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/v2ray/sub.txt"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/static/sub_zh"));
        assert!(candidates
            .iter()
            .any(|url| url
                == "https://raw.githubusercontent.com/owner/repo/main/nodes/clashmeta.yaml"));
        assert!(candidates.iter().any(|url| {
            url == "https://raw.githubusercontent.com/owner/repo/main/subs/merged/tested_within.yaml"
        }));
        assert!(candidates.iter().any(|url| {
            url == "https://raw.githubusercontent.com/owner/repo/main/subs/merged/tested_within_sudoku.yaml"
        }));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sing-box.json"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/sing-box.yaml"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/singbox.json"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/outbounds.json"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://raw.githubusercontent.com/owner/repo/main/outbounds.yaml"));
    }

    #[test]
    fn test_github_raw_seed_candidates_include_more_subscription_directories() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        for path in [
            "sub/merged.yaml",
            "sub/merged.yml",
            "subscription/clash.yaml",
            "subscription/base64.txt",
            "subscriptions/clash.yaml",
            "subscriptions/base64.txt",
            "clash/all.yaml",
            "mihomo/proxies.yml",
            "mihomo/config.yaml",
            "mihomo/config.yml",
            "mihomo/sub.yaml",
            "mihomo/sub.yml",
            "meta/clash.yaml",
            "meta/mihomo.yaml",
            "meta/proxies.yaml",
            "meta/sub.yaml",
            "config/clash.yaml",
            "config/mihomo.yaml",
            "config/proxies.yaml",
            "config/sub.yaml",
            "configs/clash.yaml",
            "configs/mihomo.yaml",
            "configs/proxies.yaml",
            "configs/sub.yaml",
            "data/clash.yaml",
            "data/mihomo.yaml",
            "data/proxies.yaml",
            "data/sub.yaml",
            "share/clash.yaml",
            "share/mihomo.yaml",
            "share/proxies.yaml",
            "share/sub.yaml",
            "yaml/clash.yaml",
            "yaml/mihomo.yaml",
            "list.txt",
        ] {
            assert!(
                candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "missing GitHub seed path {path}"
            );
        }
    }

    #[test]
    fn test_github_raw_seed_candidates_include_high_value_root_subscription_names() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        for path in [
            "c.yaml",
            "v.txt",
            "Client.txt",
            "v2",
            "ClashPremiumFree.yaml",
            "sub1.txt",
            "sub2.txt",
            "sub3.txt",
            "README.md",
        ] {
            for branch in ["main", "master"] {
                let expected =
                    format!("https://raw.githubusercontent.com/owner/repo/{branch}/{path}");
                assert!(
                    candidates.iter().any(|url| url == &expected),
                    "missing GitHub seed path {expected}"
                );
            }
        }
    }

    #[test]
    fn test_github_raw_seed_candidates_include_protocol_split_json_proxy_lists() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        for path in [
            "proxies/protocols/http/data.json",
            "proxies/protocols/http/data.txt",
            "proxies/protocols/http/data.csv",
            "proxies/protocols/https/data.json",
            "proxies/protocols/https/data.txt",
            "proxies/protocols/https/data.csv",
            "proxies/protocols/socks5/data.json",
            "proxies/protocols/socks5/data.txt",
            "proxies/protocols/socks5/data.csv",
            "proxies/all/data.json",
            "proxies/all/data.txt",
            "proxies/all/data.csv",
            "online-proxies/txt/proxies.txt",
            "online-proxies/txt/proxies-http.txt",
            "online-proxies/txt/proxies-https.txt",
            "online-proxies/txt/proxies-socks5.txt",
            "online-proxies/csv/proxies.csv",
            "online-proxies/json/proxies.json",
            "online-proxies/json/proxies-basic.json",
            "online-proxies/yaml/proxies.yaml",
            "online-proxies/yaml/proxies-basic.yaml",
            "protocols/http.csv",
            "protocols/https.csv",
            "protocols/socks5.csv",
        ] {
            assert!(
                candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "missing GitHub protocol-split proxy list path {path}"
            );
        }
        for path in [
            "proxies/protocols/socks4/data.json",
            "proxies/protocols/socks4/data.txt",
            "proxies/protocols/socks4/data.csv",
            "online-proxies/txt/proxies-socks4.txt",
        ] {
            assert!(
                !candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "GitHub seed expansion should skip unsupported socks4-only path {path}"
            );
        }
    }

    #[test]
    fn test_github_raw_seed_candidates_include_v2ray_protocol_and_region_shards() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        for path in [
            "sub/protocols/vless.txt",
            "sub/protocols/vless.yaml",
            "sub/protocols/trojan.txt",
            "sub/protocols/trojan.yaml",
            "sub/protocols/vmess.txt",
            "sub/protocols/vmess.yaml",
            "sub/protocols/ss.txt",
            "sub/protocols/ss.yaml",
            "sub/protocols/hysteria2.txt",
            "sub/protocols/hysteria2.yaml",
            "sub/continents/Europe.txt",
            "sub/continents/Europe.yaml",
            "sub/continents/Asia.txt",
            "sub/continents/Asia.yaml",
            "sub/continents/NorthAmerica.txt",
            "sub/continents/NorthAmerica.yaml",
            "sub/countries/IR.txt",
            "sub/countries/IR.yaml",
            "sub/countries/US.txt",
            "sub/countries/US.yaml",
            "sub/countries/SG.txt",
            "sub/countries/SG.yaml",
            "sub/countries/HK.txt",
            "sub/countries/HK.yaml",
            "nodes/yudou66.txt",
            "nodes/ndnode.txt",
            "nodes/v2rayshare.txt",
            "nodes/wenode.txt",
        ] {
            assert!(
                candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "missing GitHub V2Ray shard seed path {path}"
            );
        }
    }

    #[test]
    fn test_github_raw_seed_candidates_include_protocol_output_directories() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        for path in [
            "output_configs/Vless.txt",
            "output_configs/Vmess.txt",
            "output_configs/Trojan.txt",
            "output_configs/ShadowSocks.txt",
            "output_configs/Hysteria2.txt",
            "output_configs/Tuic.txt",
            "Splitted-By-Protocol/vless.txt",
            "Splitted-By-Protocol/vmess.txt",
            "Splitted-By-Protocol/trojan.txt",
            "Splitted-By-Protocol/ss.txt",
            "Splitted-By-Protocol/hysteria2.txt",
            "Splitted-By-Protocol/tuic.txt",
        ] {
            assert!(
                candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "missing GitHub protocol output seed path {path}"
            );
        }
        for path in [
            "output_configs/Socks4.txt",
            "Splitted-By-Protocol/socks4.txt",
        ] {
            assert!(
                !candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "GitHub seed expansion should skip unsupported socks4-only path {path}"
            );
        }
    }

    #[test]
    fn test_github_raw_seed_candidates_include_v2ray_subscription_split_shards() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        for path in [
            "subscriptions/v2ray/super-sub.txt",
            "subscriptions/v2ray/subs/sub1.txt",
            "subscriptions/v2ray/subs/sub2.txt",
            "subscriptions/v2ray/subs/sub3.txt",
            "subscriptions/v2ray/subs/sub4.txt",
            "subscriptions/v2ray/subs/sub5.txt",
            "subscriptions/v2ray/subs/sub6.txt",
            "subscriptions/v2ray/subs/sub7.txt",
            "subscriptions/v2ray/subs/sub8.txt",
            "subscriptions/v2ray/subs/sub9.txt",
            "subscriptions/v2ray/subs/sub10.txt",
        ] {
            assert!(
                candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "missing GitHub subscription split seed path {path}"
            );
        }
    }

    #[test]
    fn test_github_raw_seed_candidates_include_common_root_config_names() {
        let candidates = github_raw_seed_candidates("https://github.com/owner/repo");

        for path in [
            "README.md",
            "config.yaml",
            "config.yml",
            "merged.yaml",
            "merged.yml",
            "all.yml",
            "nodes.yml",
            "proxy.yaml",
            "proxy.yml",
            "proxy.json",
            "http.txt",
            "https.txt",
            "socks5.txt",
            "http.csv",
            "https.csv",
            "socks5.csv",
            "all-proxies.txt",
            "all.csv",
            "all.json",
            "free.csv",
            "free.json",
            "node.csv",
            "node.json",
            "nodes.csv",
            "nodes.json",
            "proxies.csv",
            "proxies.json",
            "proxy.csv",
            "proxylist.txt",
            "proxylist.csv",
            "proxylist.json",
            "proxylist.yaml",
            "proxylist.yml",
            "proxylist.xml",
            "proxylist.phps",
            "proxy-list.txt",
            "proxy-list.csv",
            "proxy-list.json",
            "proxy-list.yaml",
            "proxy-list.yml",
            "proxy-list-raw.txt",
            "provider.yaml",
            "provider.yml",
            "provider.json",
            "providers.yaml",
            "providers.yml",
            "providers.json",
            "proxy-providers.yaml",
            "proxy-providers.yml",
            "proxy-providers.json",
            "proxy_providers.yaml",
            "proxy_providers.yml",
            "proxy_providers.json",
        ] {
            assert!(
                candidates.iter().any(|url| url
                    == &format!("https://raw.githubusercontent.com/owner/repo/main/{path}")),
                "missing GitHub root seed path {path}"
            );
        }
        assert!(
            !candidates.iter().any(|url| url.ends_with("/socks4.txt")),
            "GitHub seed expansion should skip unsupported socks4-only feeds"
        );
        assert!(
            !candidates.iter().any(|url| url.ends_with("/docs/guide.md")),
            "GitHub seed expansion should not broaden arbitrary Markdown discovery pages"
        );
    }

    #[test]
    fn test_github_discovery_candidates_start_with_repo_metadata_for_default_branch() {
        let candidates = github_discovery_candidates("https://github.com/owner/repo");

        assert_eq!(
            candidates.first().map(String::as_str),
            Some("https://api.github.com/repos/owner/repo")
        );
        assert!(
            candidates
                .iter()
                .any(|url| url
                    == "https://api.github.com/repos/owner/repo/git/trees/main?recursive=1")
        );
        assert!(candidates.iter().any(
            |url| url == "https://api.github.com/repos/owner/repo/git/trees/master?recursive=1"
        ));
    }

    #[test]
    fn test_github_seed_candidates_accept_mirrored_blob_and_raw_urls() {
        let blob_seed =
            "https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/dev/proxies.yaml";
        let discovery = github_discovery_candidates(blob_seed);
        let raw = github_raw_seed_candidates(blob_seed);

        assert_eq!(
            discovery.first().map(String::as_str),
            Some("https://api.github.com/repos/PuddinCat/BestClash")
        );
        assert_eq!(
            discovery.get(2).map(String::as_str),
            Some("https://api.github.com/repos/PuddinCat/BestClash/contents?ref=dev")
        );
        assert_eq!(
            discovery.get(3).map(String::as_str),
            Some("https://api.github.com/repos/PuddinCat/BestClash/git/trees/dev?recursive=1")
        );
        assert_eq!(
            raw.first().map(String::as_str),
            Some("https://raw.githubusercontent.com/PuddinCat/BestClash/dev/clash.yaml")
        );
        assert!(raw.iter().any(|url| {
            url == "https://raw.githubusercontent.com/PuddinCat/BestClash/dev/sub/clash.yaml"
        }));

        let raw_seed =
            "https://gh-proxy.com/https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/dev/proxies.yaml";
        let discovery = github_discovery_candidates(raw_seed);
        let raw = github_raw_seed_candidates(raw_seed);

        assert_eq!(
            discovery.first().map(String::as_str),
            Some("https://api.github.com/repos/PuddinCat/BestClash")
        );
        assert_eq!(
            discovery.get(2).map(String::as_str),
            Some("https://api.github.com/repos/PuddinCat/BestClash/contents?ref=dev")
        );
        assert_eq!(
            discovery.get(3).map(String::as_str),
            Some("https://api.github.com/repos/PuddinCat/BestClash/git/trees/dev?recursive=1")
        );
        assert_eq!(
            raw.first().map(String::as_str),
            Some("https://raw.githubusercontent.com/PuddinCat/BestClash/dev/clash.yaml")
        );
        assert!(raw.iter().any(|url| {
            url == "https://raw.githubusercontent.com/PuddinCat/BestClash/dev/sub/clash.yaml"
        }));
    }

    #[test]
    fn test_github_seed_candidates_parse_canonical_seed_once_per_builder() {
        let source = include_str!("free_nodes.rs");
        let discovery_body = source
            .split("fn github_discovery_candidates")
            .nth(1)
            .and_then(|rest| rest.split("fn github_raw_seed_candidates").next())
            .expect("github_discovery_candidates body");
        let raw_body = source
            .split("fn github_raw_seed_candidates")
            .nth(1)
            .and_then(|rest| rest.split("fn github_seed_parts").next())
            .expect("github_raw_seed_candidates body");
        let seed_parts_body = source
            .split("fn github_seed_parts")
            .nth(1)
            .and_then(|rest| rest.split("fn github_seed_parts_from_url").next())
            .expect("github_seed_parts body");

        assert!(
            discovery_body.contains("github_seed_parts(seed)")
                && raw_body.contains("github_seed_parts(seed)")
                && seed_parts_body.matches("canonical_fetch_key(seed)").count() == 1,
            "GitHub seed builders should share one canonical seed parse for owner/repo and branch"
        );
        assert!(
            !discovery_body.contains("github_owner_repo(seed)")
                && !discovery_body.contains("github_seed_branch(seed)")
                && !raw_body.contains("github_owner_repo(seed)")
                && !raw_body.contains("github_seed_branch(seed)"),
            "GitHub seed builders should not canonicalize the same seed twice"
        );
    }

    #[test]
    fn test_github_seed_candidates_parse_url_once_for_owner_repo_and_branch() {
        let source = include_str!("free_nodes.rs");
        let discovery_body = source
            .split("fn github_discovery_candidates")
            .nth(1)
            .and_then(|rest| rest.split("fn github_raw_seed_candidates").next())
            .expect("github_discovery_candidates body");
        let raw_body = source
            .split("fn github_raw_seed_candidates")
            .nth(1)
            .and_then(|rest| rest.split("fn github_seed").next())
            .expect("github_raw_seed_candidates body");

        assert!(
            discovery_body.contains("github_seed_parts(seed)")
                && raw_body.contains("github_seed_parts(seed)"),
            "GitHub seed builders should use a single seed parser for owner/repo and branch"
        );
        assert!(
            !discovery_body.contains("github_owner_repo_from_url")
                && !discovery_body.contains("github_seed_branch_from_url")
                && !raw_body.contains("github_owner_repo_from_url")
                && !raw_body.contains("github_seed_branch_from_url"),
            "GitHub seed builders should not parse the same URL separately for owner/repo and branch"
        );
    }

    #[test]
    fn test_github_raw_url_builders_share_single_helper() {
        let source = include_str!("free_nodes.rs");
        let metadata_body = source
            .split("fn discover_github_repo_metadata_urls")
            .nth(1)
            .and_then(|rest| rest.split("fn github_api_url_capacity_hint").next())
            .expect("discover_github_repo_metadata_urls body");
        let raw_from_path_body = source
            .split("fn raw_github_url_from_path")
            .nth(1)
            .and_then(|rest| rest.split("fn raw_github_url").next())
            .expect("raw_github_url_from_path body");
        let seed_body = source
            .split("fn github_raw_seed_candidates")
            .nth(1)
            .and_then(|rest| rest.split("fn github_seed_parts").next())
            .expect("github_raw_seed_candidates body");

        for body in [metadata_body, raw_from_path_body, seed_body] {
            assert!(
                body.contains("raw_github_url("),
                "GitHub raw URL builders should share one helper"
            );
            assert!(
                !body.contains("format!(\n            \"https://raw.githubusercontent.com")
                    && !body.contains("format!(\"https://raw.githubusercontent.com"),
                "GitHub raw URL builders should not duplicate raw.githubusercontent.com format! calls"
            );
        }
    }

    #[test]
    fn test_github_repo_metadata_uses_borrowed_owner_repo_segments() {
        let source = include_str!("free_nodes.rs");
        let metadata_body = source
            .split("fn discover_github_repo_metadata_urls")
            .nth(1)
            .and_then(|rest| rest.split("fn github_api_url_capacity_hint").next())
            .expect("discover_github_repo_metadata_urls body");

        assert!(
            !metadata_body.contains("github_repo_api_owner_repo(base_url)"),
            "metadata discovery should avoid allocating owner/repo through a separate helper"
        );
        assert!(
            !metadata_body.contains("let (owner, repo)"),
            "metadata discovery should borrow owner/repo path segments directly"
        );
    }

    #[test]
    fn test_github_seed_parts_checks_host_before_owner_repo_allocation() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn github_seed_parts_from_url")
            .nth(1)
            .and_then(|rest| rest.split("fn non_default_github_seed_branch").next())
            .expect("github_seed_parts_from_url body");
        let owner_alloc = body
            .find("let owner = segments.next()?.to_string();")
            .expect("owner allocation");
        let raw_host_check = body
            .find("host.eq_ignore_ascii_case(\"raw.githubusercontent.com\")")
            .expect("raw host check");
        let github_host_check = body
            .find("host.eq_ignore_ascii_case(\"github.com\")")
            .expect("github host check");

        assert!(
            raw_host_check < owner_alloc && github_host_check < owner_alloc,
            "GitHub seed parsing should reject non-GitHub hosts before allocating owner/repo"
        );
    }

    #[test]
    fn test_github_discovery_initial_candidate_estimate_covers_expanded_seed_candidates() {
        let blob_seed = "https://github.com/owner/repo/blob/dev/proxies.yaml";
        let actual = github_raw_seed_candidates(blob_seed).len()
            + github_discovery_candidates(blob_seed).len();

        assert!(
            GITHUB_DISCOVERY_INITIAL_CANDIDATE_ESTIMATE >= actual,
            "estimate {GITHUB_DISCOVERY_INITIAL_CANDIDATE_ESTIMATE} < actual {actual}"
        );

        let crossxx_seed = "https://github.com/CrossXX-Labs/Free-Proxy/blob/dev/proxies.yaml";
        let actual_with_special_sources = github_raw_seed_candidates(crossxx_seed).len()
            + github_discovery_candidates(crossxx_seed).len();

        assert!(
            GITHUB_DISCOVERY_INITIAL_CANDIDATE_ESTIMATE >= actual_with_special_sources,
            "estimate {GITHUB_DISCOVERY_INITIAL_CANDIDATE_ESTIMATE} < actual {actual_with_special_sources}"
        );
    }

    #[test]
    fn test_discover_github_repo_metadata_urls_adds_default_branch_candidates() {
        let urls = discover_urls(
            r#"{"default_branch":"dev"}"#,
            "https://api.github.com/repos/owner/repo",
        );

        let mut expected = vec![
            "https://api.github.com/repos/owner/repo/contents?ref=dev".to_string(),
            "https://api.github.com/repos/owner/repo/git/trees/dev?recursive=1".to_string(),
        ];
        expected.extend(
            GITHUB_RAW_SEED_PATHS
                .iter()
                .map(|path| format!("https://raw.githubusercontent.com/owner/repo/dev/{path}")),
        );

        assert_eq!(urls, expected);
    }

    #[test]
    fn test_github_raw_seed_candidates_include_crossxx_special_sources_case_insensitive() {
        let candidates = github_raw_seed_candidates("https://github.com/CrossXX-Labs/Free-Proxy");

        assert!(candidates
            .iter()
            .any(|url| url == "http://clash.crossxx.com/"));
        assert!(candidates
            .iter()
            .any(|url| url == "https://www.freeclash.top/ui/free_clash"));
    }

    #[test]
    fn test_build_config_candidates_caps_equivalent_github_mirrors() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let raw = "https://raw.githubusercontent.com/owner/repo/main/clash.yaml";
        let preferred_mirror =
            "https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/clash.yaml";
        let secondary_mirror =
            "https://gh-proxy.com/https://raw.githubusercontent.com/owner/repo/main/clash.yaml";
        let unrelated = "https://raw.githubusercontent.com/owner/repo/main/other.yaml";
        let mut configs = HashMap::new();
        configs.insert(raw.to_string(), Arc::clone(&source));
        configs.insert(preferred_mirror.to_string(), Arc::clone(&source));
        configs.insert(secondary_mirror.to_string(), Arc::clone(&source));
        configs.insert(unrelated.to_string(), Arc::clone(&source));

        let candidates = build_config_candidates(configs);
        let equivalent: Vec<&ConfigCandidate> = candidates
            .iter()
            .filter(|candidate| candidate.fetch_key == raw)
            .collect();

        assert_eq!(equivalent.len(), GITHUB_RAW_MIRROR_PREFIXES.len() + 5);
        assert!(equivalent
            .iter()
            .any(|candidate| candidate.url == preferred_mirror));
        assert!(equivalent
            .iter()
            .any(|candidate| candidate.url == secondary_mirror));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url
                == "https://ghproxy.net/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url
                == "https://ghfast.top/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url
                == "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url
                == "https://gh.ddlc.top/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url == "https://cdn.jsdelivr.net/gh/owner/repo@main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url == "https://fastly.jsdelivr.net/gh/owner/repo@main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url == "https://gcore.jsdelivr.net/gh/owner/repo@main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| {
            candidate.url == "https://rawgithubusercontent.deno.dev/owner/repo/main/clash.yaml"
        }));
        assert!(equivalent.iter().any(|candidate| candidate.url == raw));
        assert!(candidates
            .iter()
            .any(|candidate| candidate.fetch_key == unrelated));
    }

    #[test]
    fn test_build_config_candidates_keeps_bounded_multiple_github_mirror_fallbacks() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let raw = "https://raw.githubusercontent.com/owner/repo/main/clash.yaml";
        let mut configs = HashMap::new();
        configs.insert(raw.to_string(), Arc::clone(&source));

        let candidates = build_config_candidates(configs);

        assert_eq!(candidates.len(), GITHUB_RAW_MIRROR_PREFIXES.len() + 5);
        assert_eq!(
            candidates
                .iter()
                .map(|candidate| candidate.url.as_str())
                .collect::<Vec<_>>(),
            vec![
                "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://gcore.jsdelivr.net/gh/owner/repo@main/clash.yaml",
                "https://fastly.jsdelivr.net/gh/owner/repo@main/clash.yaml",
                "https://cdn.jsdelivr.net/gh/owner/repo@main/clash.yaml",
                "https://rawgithubusercontent.deno.dev/owner/repo/main/clash.yaml",
                "https://ghfast.top/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://ghproxy.net/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://gh-proxy.com/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://ghproxy.imciel.com/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://gh.monlor.com/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://gh.ddlc.top/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://ghfile.geekertao.top/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://ghproxy.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://gh.con.sh/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://hub.gitmirror.com/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://ghproxy.vip/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://github.akams.cn/https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
                "https://raw.githubusercontent.com/owner/repo/main/clash.yaml",
            ]
        );
        assert!(candidates
            .iter()
            .all(|candidate| candidate.fetch_key == raw));
    }

    #[test]
    fn test_build_config_candidates_uses_fast_path_mirror_for_raw_github_primary() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "puddincat".into(),
            label: "PuddinCat".into(),
            seed: "https://github.com/PuddinCat/BestClash".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut configs = HashMap::new();
        configs.insert(
            "https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml"
                .to_string(),
            source,
        );

        let candidates = build_config_candidates(configs);

        assert_eq!(
            candidates.first().map(|candidate| candidate.url.as_str()),
            Some(
            "https://gh.llkk.cc/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"
            )
        );
    }

    #[test]
    fn test_add_config_or_page_canonicalizes_github_mirror_blob_before_insert() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "puddincat".into(),
            label: "PuddinCat".into(),
            seed: "https://github.com/PuddinCat/BestClash".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut configs = HashMap::<String, Arc<CandidateSource>>::new();
        let mut page_queue = VecDeque::<ConfigCandidate>::new();
        let mut visited_pages = HashSet::<String>::new();
        let mut visited_page_fetch_keys = HashSet::<String>::new();

        add_config_or_page(
            &mut configs,
            &mut page_queue,
            &mut visited_pages,
            &mut visited_page_fetch_keys,
            "https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml",
            &source,
        );
        add_config_or_page(
            &mut configs,
            &mut page_queue,
            &mut visited_pages,
            &mut visited_page_fetch_keys,
            "https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml",
            &source,
        );

        assert_eq!(configs.len(), 1);
        assert!(configs.contains_key(
            "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"
        ));
        assert!(page_queue.is_empty());
    }

    #[test]
    fn test_add_config_or_page_keeps_github_raw_extensionless_page_discovery_indexes() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "mermeroo-subscription-links-index".into(),
            label: "mermeroo subscription links index".into(),
            seed: "https://github.com/mermeroo/V2RAY-CLASH-BASE64-Subscription.Links/blob/main/SUB%20LINKS".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut configs = HashMap::<String, Arc<CandidateSource>>::new();
        let mut page_queue = VecDeque::<ConfigCandidate>::new();
        let mut visited_pages = HashSet::<String>::new();
        let mut visited_page_fetch_keys = HashSet::<String>::new();

        add_config_or_page(
            &mut configs,
            &mut page_queue,
            &mut visited_pages,
            &mut visited_page_fetch_keys,
            "https://github.com/mermeroo/V2RAY-CLASH-BASE64-Subscription.Links/blob/main/SUB%20LINKS",
            &source,
        );

        assert!(configs.is_empty());
        assert_eq!(page_queue.len(), 1);
        assert_eq!(
            page_queue.front().map(|candidate| candidate.url.as_str()),
            Some(
                "https://raw.githubusercontent.com/mermeroo/V2RAY-CLASH-BASE64-Subscription.Links/main/SUB%20LINKS"
            )
        );
    }

    #[test]
    fn test_add_config_or_page_rejects_github_raw_extensionless_indexes_without_page_discovery() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "plain-source".into(),
            label: "plain source".into(),
            seed: "https://github.com/mermeroo/V2RAY-CLASH-BASE64-Subscription.Links".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut configs = HashMap::<String, Arc<CandidateSource>>::new();
        let mut page_queue = VecDeque::<ConfigCandidate>::new();
        let mut visited_pages = HashSet::<String>::new();
        let mut visited_page_fetch_keys = HashSet::<String>::new();

        add_config_or_page(
            &mut configs,
            &mut page_queue,
            &mut visited_pages,
            &mut visited_page_fetch_keys,
            "https://raw.githubusercontent.com/mermeroo/V2RAY-CLASH-BASE64-Subscription.Links/main/SUB%20LINKS",
            &source,
        );

        assert!(configs.is_empty());
        assert!(page_queue.is_empty());
    }

    #[test]
    fn test_add_config_or_page_skips_unsupported_socks4_only_raw_candidates() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "proxy-lists".into(),
            label: "Proxy Lists".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 1,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut configs = HashMap::<String, Arc<CandidateSource>>::new();
        let mut page_queue = VecDeque::<ConfigCandidate>::new();
        let mut visited_pages = HashSet::<String>::new();
        let mut visited_page_fetch_keys = HashSet::<String>::new();

        for url in [
            "https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/protocols/socks4/data.json",
            "https://raw.githubusercontent.com/TheSpeedX/SOCKS-List/master/socks4.txt",
            "https://cdn.jsdelivr.net/gh/iplocate/free-proxy-list@main/protocols/socks4.txt",
            "https://cdn.jsdelivr.net/gh/proxifly/free-proxy-list@main/proxies/protocols/socks5/data.json",
        ] {
            add_config_or_page(
                &mut configs,
                &mut page_queue,
                &mut visited_pages,
                &mut visited_page_fetch_keys,
                url,
                &source,
            );
        }

        assert_eq!(configs.len(), 1);
        assert!(configs
            .keys()
            .all(|url| !url.to_ascii_lowercase().contains("socks4")));
        assert!(configs
            .keys()
            .any(|url| url.contains("proxies/protocols/socks5/data.json")));
        assert!(page_queue.is_empty());
    }

    #[test]
    fn test_resolve_candidates_deduplicates_puddincat_blob_mirror_and_raw_refs() {
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![SourceInput {
                    id: "puddincat".into(),
                    label: "PuddinCat".into(),
                    seed: "https://puddincat.example/BestClash".into(),
                    rank: 0,
                    update_interval_hours: 24,
                    page_discovery: false,
                    github_discovery: false,
                    raw_candidates: vec![
                        "https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml"
                            .into(),
                        "https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml"
                            .into(),
                    ],
                    candidate_urls: vec![],
                }],
            },
            enabled_source_ids: vec!["puddincat".into()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 8,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };

        let candidates = resolve_candidates(&input);
        let fetch_keys = candidates
            .iter()
            .map(|candidate| candidate.fetch_key.as_str())
            .collect::<HashSet<_>>();

        assert_eq!(fetch_keys.len(), 1);
        assert_eq!(candidates.len(), MAX_EQUIVALENT_FETCH_CANDIDATES);
        assert_eq!(
            candidates[0].url,
            "https://gh.llkk.cc/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"
        );
        assert_eq!(
            candidates[1].url,
            "https://gcore.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml"
        );
        assert_eq!(
            candidates[2].url,
            "https://fastly.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml"
        );
        assert_eq!(
            candidates[3].url,
            "https://cdn.jsdelivr.net/gh/PuddinCat/BestClash@main/proxies.yaml"
        );
        assert_eq!(
            candidates[4].url,
            "https://rawgithubusercontent.deno.dev/PuddinCat/BestClash/main/proxies.yaml"
        );
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://gh-proxy.com/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://gh.ddlc.top/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://gh.llkk.cc/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://ghproxy.cc/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://gh.con.sh/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://hub.gitmirror.com/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://ghproxy.vip/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://github.akams.cn/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
        assert!(candidates.iter().any(|candidate| candidate.url
            == "https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"));
    }

    #[test]
    fn test_resolve_candidates_prefers_explicit_raw_without_github_seed_expansion() {
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![SourceInput {
                    id: "github-static".into(),
                    label: "GitHub Static".into(),
                    seed: "https://github.com/owner/repo".into(),
                    rank: 0,
                    update_interval_hours: 24,
                    page_discovery: false,
                    github_discovery: false,
                    raw_candidates: vec![
                        "https://raw.githubusercontent.com/owner/repo/main/known.yaml".into(),
                    ],
                    candidate_urls: vec![],
                }],
            },
            enabled_source_ids: vec!["github-static".into()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 8,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };

        let candidates = resolve_candidates(&input);
        let expected_fetch_key = "https://raw.githubusercontent.com/owner/repo/main/known.yaml";

        assert_eq!(candidates.len(), MAX_EQUIVALENT_FETCH_CANDIDATES);
        assert!(candidates
            .iter()
            .all(|candidate| candidate.fetch_key == expected_fetch_key));
        assert_eq!(
            candidates.first().map(|candidate| candidate.url.as_str()),
            Some("https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/known.yaml")
        );
        assert!(!candidates.iter().any(|candidate| candidate.fetch_key
            == "https://raw.githubusercontent.com/owner/repo/main/config/clash.yaml"));
    }

    #[test]
    fn test_build_config_candidates_preallocates_primaries_without_collect() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(configs")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains("Vec::<ConfigCandidate>::with_capacity(configs.len())"),
            "primary config candidates should be preallocated from the config count"
        );
        assert!(
            !body.contains(".collect();"),
            "primary config candidates should be filled directly instead of collecting an iterator"
        );
    }

    #[test]
    fn test_build_config_candidates_preallocates_fetch_key_counts() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(configs")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains(
                "HashMap::<String, usize>::with_capacity(primaries.len().min(CONFIG_CANDIDATE_LIMIT))"
            ),
            "fetch key counters should be preallocated to the bounded candidate capacity"
        );
        assert!(
            !body.contains("let mut fetch_key_counts = HashMap::<String, usize>::new();"),
            "fetch key counters should not start from an empty HashMap"
        );
    }

    #[test]
    fn test_build_config_candidates_preallocates_candidate_url_index() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(configs")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains(
                "CandidateUrlIndex::with_capacity(primaries.len().min(CONFIG_CANDIDATE_LIMIT))"
            ),
            "candidate URL index should be preallocated to the bounded candidate capacity"
        );
        assert!(
            !body.contains("let mut seen_urls = CandidateUrlIndex::default();"),
            "candidate URL index should not start from an empty HashMap"
        );
    }

    #[test]
    fn test_build_config_candidates_reuses_cached_github_mirrorable_flag() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(configs")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains("candidate.github_mirrorable"),
            "GitHub mirror expansion should reuse the ConfigCandidate mirrorable flag"
        );
        assert!(
            !body.contains("is_github_mirrorable_url"),
            "GitHub mirror expansion should not repeatedly parse the same fetch_key"
        );
    }

    #[test]
    fn test_build_config_candidates_iterates_raw_mirror_prefixes_without_index_option() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(configs")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains("for prefix in GITHUB_RAW_MIRROR_PREFIXES"),
            "raw mirror candidate expansion should iterate every raw prefix after path mirrors"
        );
        assert!(
            !body.contains("for mirror_index in 0..GITHUB_RAW_MIRROR_PREFIXES.len()")
                && !body.contains("for mirror_index in 1..GITHUB_RAW_MIRROR_PREFIXES.len()"),
            "raw mirror candidate expansion should not use index bounds in the hot path"
        );
        assert!(
            !body.contains("unchecked_github_mirror_url(&candidate.fetch_key, mirror_index)"),
            "raw mirror candidate expansion should avoid Option-returning indexed helpers"
        );
    }

    #[test]
    fn test_build_config_candidates_reuses_path_mirror_suffixes() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn build_config_candidates(configs")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains("github_path_mirror_suffixes"),
            "path mirror expansion should precompute raw GitHub suffixes once per candidate"
        );
        assert!(
            !body.contains("nth_github_path_mirror_url"),
            "path mirror expansion should not parse the same raw GitHub URL once per mirror prefix"
        );
    }

    #[test]
    fn test_github_path_mirror_suffixes_preallocates_candidate_slots() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn github_path_mirror_suffixes(candidates")
            .nth(1)
            .and_then(|rest| rest.split("fn push_unique_config_candidate").next())
            .expect("github_path_mirror_suffixes body");

        assert!(
            body.contains("Vec::<(usize, String)>::with_capacity"),
            "github_path_mirror_suffixes should preallocate result slots"
        );
        assert!(
            body.contains("candidates.len().min(CONFIG_CANDIDATE_LIMIT)"),
            "github_path_mirror_suffixes should cap preallocation to the candidate limit"
        );
        assert!(
            !body.contains("Vec::<(usize, String)>::new()"),
            "github_path_mirror_suffixes should avoid grow-from-zero allocation"
        );
    }

    #[test]
    fn test_push_unique_config_candidate_from_candidate_defers_full_candidate_construction() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn push_unique_config_candidate_from_candidate(")
            .nth(1)
            .and_then(|rest| rest.split("#[derive(Debug, Default)]").next())
            .expect("push_unique_config_candidate_from_candidate body");

        assert!(
            body.contains("base.fetch_key.as_str()"),
            "push_unique_config_candidate_from_candidate should check limits with the cached fetch key"
        );
        assert!(
            body.contains("let candidate = ConfigCandidate {"),
            "accepted candidates should construct directly after duplicate and limit checks"
        );
        assert!(
            body.contains("fetch_key: base.fetch_key.clone(),"),
            "accepted candidates should reuse the precomputed fetch key"
        );
        assert!(
            !body.contains("let candidate = ConfigCandidate::from_candidate_source_ref(url, source);"),
            "push_unique_config_candidate_from_candidate should not fully construct candidates before duplicate and equivalent limit checks"
        );
    }

    #[test]
    fn test_push_unique_config_candidate_from_candidate_updates_fetch_key_counts_in_place() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn push_unique_config_candidate_from_candidate(")
            .nth(1)
            .and_then(|rest| rest.split("#[derive(Debug, Default)]").next())
            .expect("push_unique_config_candidate_from_candidate body");

        assert!(
            body.contains("fetch_key_counts.get_mut(base.fetch_key.as_str())"),
            "existing equivalent fetch key counters should be incremented in place"
        );
        assert!(
            !body.contains("fetch_key_counts.insert(base.fetch_key.clone(), equivalent_count + 1);"),
            "accepted mirror candidates should not clone and insert the same fetch key on every increment"
        );
    }

    #[test]
    fn test_build_config_candidates_inlines_canonical_raw_fallback() {
        let source = include_str!("free_nodes.rs");
        let production_source = source.split("#[cfg(test)]").next().unwrap_or(source);
        let body = source
            .split("fn build_config_candidates(configs")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_suffixes").next())
            .expect("build_config_candidates body");

        assert!(
            body.contains("if candidate.github_mirrorable {"),
            "canonical raw fallback should use the cached mirrorable flag directly"
        );
        assert!(
            body.contains("candidate.fetch_key.clone()"),
            "canonical raw fallback should clone the existing fetch key directly"
        );
        assert!(
            !production_source.contains("fn canonical_github_raw_fallback_url("),
            "avoid a release-size-only wrapper around candidate.fetch_key.clone()"
        );
    }

    #[test]
    fn test_github_path_mirror_suffix_uses_path_capacity() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn github_path_mirror_suffix(url: &str)")
            .nth(1)
            .and_then(|rest| rest.split("fn github_path_mirror_url_from_suffix").next())
            .expect("github_path_mirror_suffix body");

        assert!(
            body.contains("let path_capacity = parsed.path().len().saturating_sub(1);"),
            "github_path_mirror_suffix should size suffix storage from the raw path"
        );
        assert!(
            !body.contains("String::with_capacity(url.len())"),
            "github_path_mirror_suffix should not reserve capacity for scheme and host bytes"
        );
    }

    #[test]
    fn test_github_raw_path_mirror_builds_url_without_intermediate_suffix_allocation() {
        let source = include_str!("free_nodes.rs");
        let old_helper = ["github_raw_path_mirror", "_suffix_from_path_suffix"].concat();
        assert!(
            !source.contains(&format!("fn {old_helper}")),
            "raw-path mirrors should build the final URL directly instead of allocating an intermediate suffix"
        );

        let body = source
            .split_once("fn github_raw_path_mirror_url_from_path_suffix")
            .and_then(|(_, rest)| rest.split_once("fn has_github_mirrorable_host_hint"))
            .map(|(body, _)| body)
            .expect("github_raw_path_mirror_url_from_path_suffix body");

        assert!(
            body.contains("suffix.find('@')"),
            "raw-path mirror URL construction should still normalize owner/repo@branch/path suffixes"
        );
        assert!(
            !body.contains("raw_suffix"),
            "raw-path mirror URL construction should not allocate a separate raw_suffix"
        );
    }

    #[test]
    fn test_candidate_url_index_with_capacity_preallocates_buckets() {
        let index = CandidateUrlIndex::with_capacity(64);

        assert!(index.capacity() >= 64);
    }

    #[test]
    fn test_config_candidate_url_index_deduplicates_without_losing_hash_collisions() {
        let urls = insert_config_candidate_urls_with_forced_fingerprint_for_testing([
            "https://example.com/a.yaml",
            "https://example.com/b.yaml",
            "https://example.com/a.yaml",
        ]);

        assert_eq!(
            urls,
            vec![
                "https://example.com/a.yaml".to_string(),
                "https://example.com/b.yaml".to_string(),
            ]
        );
    }

    #[test]
    fn test_fetch_queue_skips_duplicate_mirror_after_success_only() {
        let source = SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let mirror = ConfigCandidate::from_source_ref(
            "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
                .into(),
            &source,
        );
        let raw = ConfigCandidate::from_source_ref(
            "https://raw.githubusercontent.com/owner/repo/main/clash.yaml".into(),
            &source,
        );

        let mut queue = FetchQueueState::new(vec![mirror.clone(), raw.clone()]);
        let FetchQueueAction::Fetch {
            fetch_key,
            candidate,
        } = next_fetch_action(&mut queue)
        else {
            panic!("expected first candidate to be fetched");
        };
        assert_eq!(candidate.url, mirror.url);
        finish_fetch_candidate(&mut queue, fetch_key, false);
        assert!(matches!(
            next_fetch_action(&mut queue),
            FetchQueueAction::Fetch { .. }
        ));

        let mut queue = FetchQueueState::new(vec![mirror.clone(), raw]);
        let FetchQueueAction::Fetch { fetch_key, .. } = next_fetch_action(&mut queue) else {
            panic!("expected first candidate to be fetched");
        };
        finish_fetch_candidate(&mut queue, fetch_key, true);
        let FetchQueueAction::Skip(skipped) = next_fetch_action(&mut queue) else {
            panic!("expected successful duplicate to be skipped");
        };
        assert_eq!(
            canonical_fetch_key(&skipped.url),
            canonical_fetch_key(&mirror.url)
        );
    }

    #[test]
    fn test_fetch_queue_drops_successful_duplicate_mirrors_in_one_skip() {
        let source = SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let mirror = ConfigCandidate::from_source_ref(
            "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
                .into(),
            &source,
        );
        let raw = ConfigCandidate::from_source_ref(
            "https://raw.githubusercontent.com/owner/repo/main/clash.yaml".into(),
            &source,
        );
        let proxy = ConfigCandidate::from_source_ref(
            "https://ghproxy.net/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
                .into(),
            &source,
        );
        let unrelated = ConfigCandidate::from_source_ref(
            "https://raw.githubusercontent.com/owner/repo/main/other.yaml".into(),
            &source,
        );
        let mut queue = FetchQueueState::new(vec![mirror.clone(), raw, proxy, unrelated.clone()]);
        let FetchQueueAction::Fetch { fetch_key, .. } = next_fetch_action(&mut queue) else {
            panic!("expected first candidate to be fetched");
        };

        finish_fetch_candidate(&mut queue, fetch_key, true);
        let FetchQueueAction::Skip(skipped) = next_fetch_action(&mut queue) else {
            panic!("expected one duplicate skip status");
        };

        assert_eq!(
            canonical_fetch_key(&skipped.url),
            canonical_fetch_key(&mirror.url)
        );
        assert_eq!(queue.queue.len(), 1);
        assert_eq!(
            queue.queue.front().map(|candidate| candidate.url.as_str()),
            Some(unrelated.url.as_str())
        );
    }

    #[test]
    fn test_fetch_queue_preallocates_state_for_candidate_count() {
        let source = SourceInput {
            id: "bulk".into(),
            label: "Bulk".into(),
            seed: "https://bulk.example.com".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let candidates = (0..64)
            .map(|index| {
                ConfigCandidate::from_source_ref(
                    format!("https://bulk.example.com/{index}.yaml"),
                    &source,
                )
            })
            .collect::<Vec<_>>();

        let queue = FetchQueueState::new(candidates);

        assert_eq!(queue.queue.len(), 64);
        assert!(queue.in_flight.capacity() >= 64);
        assert!(queue.successful.capacity() >= 64);
    }

    #[test]
    fn test_fetch_queue_waiter_wakes_after_in_flight_candidate_finishes() {
        let source = SourceInput {
            id: "github".into(),
            label: "GitHub".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let mirror = ConfigCandidate::from_source_ref(
            "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/clash.yaml"
                .into(),
            &source,
        );
        let raw = ConfigCandidate::from_source_ref(
            "https://raw.githubusercontent.com/owner/repo/main/clash.yaml".into(),
            &source,
        );
        let queue = shared_fetch_queue(vec![mirror, raw.clone()]);

        let FetchQueueAction::Fetch { fetch_key, .. } =
            next_fetch_action_blocking(&queue).expect("first fetch action")
        else {
            panic!("expected first candidate to be fetched");
        };

        let (tx, rx) = std::sync::mpsc::channel();
        let waiter_queue = Arc::clone(&queue);
        let waiter = thread::spawn(move || {
            let action = next_fetch_action_blocking(&waiter_queue).expect("fallback action");
            let is_raw_fallback = matches!(
                action,
                FetchQueueAction::Fetch { candidate, .. } if candidate.url == raw.url
            );
            tx.send(is_raw_fallback).unwrap();
        });

        assert!(rx.recv_timeout(Duration::from_millis(50)).is_err());
        finish_fetch_candidate_and_notify(&queue, fetch_key, false);
        assert!(rx.recv_timeout(Duration::from_secs(1)).unwrap());
        waiter.join().unwrap();
    }

    #[test]
    fn test_fetch_candidate_uses_full_timeout_for_each_same_source_candidate() {
        let source = SourceInput {
            id: "page".into(),
            label: "Page".into(),
            seed: "https://page.example.com/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let mut fetch_timeout_seconds_by_source = HashMap::new();
        fetch_timeout_seconds_by_source.insert(source.id.clone(), 3);
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source,
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let seen_timeouts = Arc::new(Mutex::new(Vec::<u64>::new()));
        let timeout_recorder = Arc::clone(&seen_timeouts);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            _url: &str,
                            timeout: u64,
                            _agent_cache: &mut AgentCache| {
            timeout_recorder.lock().unwrap().push(timeout);
            Err("forced fetch miss".to_string())
        };
        let mut agent_cache = AgentCache::default();

        for path in ["a.yaml", "b.yaml"] {
            let candidate = ConfigCandidate::from_source_ref(
                format!("https://page.example.com/{path}"),
                &source,
            );
            assert!(!fetch_candidate_with_fetcher(
                &input,
                candidate,
                &mut proxies,
                &mut statuses,
                &mut agent_cache,
                &fetcher,
            ));
        }

        assert_eq!(*seen_timeouts.lock().unwrap(), vec![3, 3]);
        assert!(proxies.is_empty());
        assert_eq!(statuses.len(), 2);
    }

    #[test]
    fn test_free_nodes_response_body_limit_covers_large_aggregate_feeds() {
        assert_eq!(FREE_NODES_RESPONSE_BODY_LIMIT_BYTES, 64 * 1024 * 1024);
        assert!(FREE_NODES_RESPONSE_BODY_LIMIT_BYTES > 33 * 1024 * 1024);
    }

    #[test]
    fn test_source_budget_allows_multiple_request_timeouts_and_bounds_source_fetch() {
        let source = SourceInput {
            id: "deadline".into(),
            label: "Deadline".into(),
            seed: "https://deadline.example.com/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let mut fetch_timeout_seconds_by_source = HashMap::new();
        fetch_timeout_seconds_by_source.insert(source.id.clone(), 3);
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source,
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let source = CandidateSource::from_source(&source);
        let source_deadlines = Arc::new(Mutex::new(HashMap::from([(
            source.id.clone(),
            Instant::now() - Duration::from_secs(4),
        )])));

        let request_timeout = remaining_source_timeout(&input, &source, &source_deadlines)
            .expect("source budget must outlive one request timeout");
        assert_eq!(request_timeout, 3);

        source_deadlines
            .lock()
            .unwrap()
            .insert(source.id.clone(), Instant::now() - Duration::from_secs(31));
        let error = remaining_source_timeout(&input, &source, &source_deadlines)
            .expect_err("expired source budget must stop more candidates");

        assert!(error.contains("source fetch timed out after 30s"));
    }

    #[test]
    fn test_fetch_candidate_collects_proxies_and_statuses_without_shared_locks() {
        let source = SourceInput {
            id: "page".into(),
            label: "Page".into(),
            seed: "https://page.example.com/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate =
            ConfigCandidate::from_source_ref("https://page.example.com/a.yaml".into(), &source);
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            Ok(
                "proxies:\n  - name: fast\n    type: ss\n    server: fast.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\nproxy-groups:\n  - name: AUTO\n    type: url-test\n    proxies:\n      - fast\n    url: https://probe.example.com/health.yaml\n"
                    .to_string(),
            )
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(proxies.len(), 1);
        assert_eq!(
            *fetched_urls.lock().unwrap(),
            vec!["https://page.example.com/a.yaml".to_string()]
        );
        assert_eq!(
            proxies[0]
                .proxy
                .get("name")
                .and_then(string_value)
                .as_deref(),
            Some("fast")
        );
        assert_eq!(proxies[0].date_label, "日期 2026-06-19");
        assert_eq!(proxies[0].date_token, 20260619);
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 1);
    }

    #[test]
    fn test_fetch_candidate_follows_yaml_proxy_provider_urls() {
        let source = SourceInput {
            id: "provider".into(),
            label: "Provider".into(),
            seed: "https://provider.example.com/config.yaml".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://provider.example.com/config.yaml".into(),
            &source,
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.yaml") {
                Ok(
                    "proxy-providers:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n"
                        .to_string(),
                )
            } else {
                Ok(
                    "proxies:\n  - name: provider-node\n    type: ss\n    server: provider.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(
            *fetched_urls.lock().unwrap(),
            vec![
                "https://provider.example.com/config.yaml".to_string(),
                "https://provider.example.com/providers/daily.yaml?target=clash".to_string(),
            ]
        );
        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0]
                .proxy
                .get("name")
                .and_then(string_value)
                .as_deref(),
            Some("provider-node")
        );
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 1);
    }

    #[test]
    fn test_fetch_candidate_follows_base64_yaml_proxy_provider_urls() {
        let source = SourceInput {
            id: "base64-provider".into(),
            label: "Base64 Provider".into(),
            seed: "https://provider.example.com/config.txt".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://provider.example.com/config.txt".into(),
            &source,
        );
        let encoded_config = STANDARD.encode(
            "proxy-providers:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n",
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.txt") {
                Ok(encoded_config.clone())
            } else {
                Ok(
                    "proxies:\n  - name: decoded-provider-node\n    type: ss\n    server: decoded-provider.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(
            *fetched_urls.lock().unwrap(),
            vec![
                "https://provider.example.com/config.txt".to_string(),
                "https://provider.example.com/providers/daily.yaml?target=clash".to_string(),
            ]
        );
        assert_eq!(
            proxies
                .iter()
                .filter_map(|proxy| proxy.proxy.get("name").and_then(string_value))
                .collect::<Vec<_>>(),
            vec!["decoded-provider-node"]
        );
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 1);
    }

    #[test]
    fn test_fetch_candidate_follows_embedded_base64_yaml_proxy_provider_urls() {
        let source = SourceInput {
            id: "embedded-base64-provider".into(),
            label: "Embedded Base64 Provider".into(),
            seed: "https://provider.example.com/page/config.html".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://provider.example.com/page/config.html".into(),
            &source,
        );
        let encoded_config = STANDARD.encode(
            "proxy-providers:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n",
        );
        let embedded_config = format!("<script>window.sub='{encoded_config}';</script>");
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.html") {
                Ok(embedded_config.clone())
            } else {
                Ok(
                    "proxies:\n  - name: embedded-provider-node\n    type: ss\n    server: embedded-provider.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(
            *fetched_urls.lock().unwrap(),
            vec![
                "https://provider.example.com/page/config.html".to_string(),
                "https://provider.example.com/page/providers/daily.yaml?target=clash".to_string(),
            ]
        );
        assert_eq!(
            proxies
                .iter()
                .filter_map(|proxy| proxy.proxy.get("name").and_then(string_value))
                .collect::<Vec<_>>(),
            vec!["embedded-provider-node"]
        );
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 1);
    }

    #[test]
    fn test_provider_followup_fetch_reuses_first_parsed_proxy_vec() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn fetch_discovered_provider_proxies_with_fetcher")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_provider_followup_urls").next())
            .expect("fetch_discovered_provider_proxies_with_fetcher body");

        assert!(
            body.contains("let mut proxies = Option::<Vec<Map<String, Value>>>::None;"),
            "provider follow-up should lazily initialize the result Vec"
        );
        assert!(
            body.contains("Some(existing) => existing.extend(parsed_proxies),"),
            "provider follow-up should extend only after the first parsed proxy Vec is already reused"
        );
        assert!(
            body.contains("None => proxies = Some(parsed_proxies),"),
            "provider follow-up should reuse the first parse_proxies Vec without copying it into an empty Vec"
        );
        assert!(
            !body.contains("let mut proxies = Vec::new();"),
            "provider follow-up should not allocate an empty result Vec before the first successful provider parse"
        );
    }

    #[test]
    fn test_provider_followup_urls_skip_plain_text_without_provider_hint() {
        let urls = provider_followup_urls_with_decoded_candidates(
            "proxies:\n  - name: inline\n    type: ss\n    server: inline.example.com\n    port: 443\n",
            "https://provider.example.com/config.yaml",
        );

        assert!(urls.is_empty());
    }

    #[test]
    fn test_fetch_candidate_follows_scalar_yaml_proxy_provider_urls() {
        let source = SourceInput {
            id: "scalar-provider".into(),
            label: "Scalar Provider".into(),
            seed: "https://provider.example.com/config.yaml".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://provider.example.com/config.yaml".into(),
            &source,
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.yaml") {
                Ok("proxy-providers:\n  daily: ./providers/daily.yaml?target=clash\n".to_string())
            } else {
                Ok(
                    "proxies:\n  - name: scalar-provider-node\n    type: ss\n    server: scalar.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(
            *fetched_urls.lock().unwrap(),
            vec![
                "https://provider.example.com/config.yaml".to_string(),
                "https://provider.example.com/providers/daily.yaml?target=clash".to_string(),
            ]
        );
        assert_eq!(
            proxies
                .iter()
                .filter_map(|proxy| proxy.proxy.get("name").and_then(string_value))
                .collect::<Vec<_>>(),
            vec!["scalar-provider-node"]
        );
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 1);
    }

    #[test]
    fn test_fetch_candidate_follows_list_yaml_proxy_provider_urls() {
        let source = SourceInput {
            id: "list-provider".into(),
            label: "List Provider".into(),
            seed: "https://provider.example.com/config.yaml".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://provider.example.com/config.yaml".into(),
            &source,
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.yaml") {
                Ok(
                    "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nproxy-providers:\n  - name: daily\n    type: http\n    url: ./providers/daily.yaml?target=clash\n"
                        .to_string(),
                )
            } else if url.contains("/providers/daily.yaml") {
                Ok(
                    "proxies:\n  - name: list-provider-node\n    type: ss\n    server: list.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            } else {
                panic!("unexpected provider follow-up fetch: {url}");
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(
            *fetched_urls.lock().unwrap(),
            vec![
                "https://provider.example.com/config.yaml".to_string(),
                "https://provider.example.com/providers/daily.yaml?target=clash".to_string(),
            ]
        );
        assert_eq!(
            proxies
                .iter()
                .filter_map(|proxy| proxy.proxy.get("name").and_then(string_value))
                .collect::<Vec<_>>(),
            vec!["list-provider-node"]
        );
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 1);
    }

    #[test]
    fn test_fetch_candidate_follows_more_provider_urls_without_truncating_common_aggregates() {
        let source = SourceInput {
            id: "many-provider".into(),
            label: "Many Provider".into(),
            seed: "https://provider.example.com/config.yaml".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://provider.example.com/config.yaml".into(),
            &source,
        );
        let provider_config = format!(
            "proxy-providers:\n{}",
            (0..12)
                .map(|index| format!(
                    "  provider-{index:02}:\n    type: http\n    url: ./providers/provider-{index:02}.yaml?target=clash\n"
                ))
                .collect::<String>()
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.yaml") {
                return Ok(provider_config.clone());
            }
            let index = url
                .split("/provider-")
                .nth(1)
                .and_then(|value| value.split('.').next())
                .unwrap_or("missing");
            Ok(format!(
                "proxies:\n  - name: provider-{index}\n    type: ss\n    server: provider-{index}.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
            ))
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        let names = proxies
            .iter()
            .filter_map(|proxy| proxy.proxy.get("name").and_then(string_value))
            .collect::<Vec<_>>();
        assert_eq!(names.len(), 12);
        assert!(names.iter().any(|name| name == "provider-00"));
        assert!(names.iter().any(|name| name == "provider-11"));
        assert_eq!(fetched_urls.lock().unwrap().len(), 13);
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 12);
    }

    #[test]
    fn test_provider_followup_decoded_candidates_stop_without_full_generic_walk() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn provider_followup_urls_with_decoded_candidates")
            .nth(1)
            .and_then(|rest| {
                rest.split("fn fetch_provider_followup_text_with_fetcher")
                    .next()
            })
            .expect("provider decoded follow-up helper body");

        assert!(
            !body.contains("visit_decoded_candidates(text"),
            "provider follow-up should use a specialized early-stop decoded scan"
        );
    }

    #[test]
    fn test_provider_followup_embedded_base64_lazily_initializes_decoded_storage() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn provider_followup_urls_from_embedded_base64")
            .nth(1)
            .and_then(|rest| {
                rest.split("fn fetch_provider_followup_text_with_fetcher")
                    .next()
            })
            .expect("provider embedded base64 follow-up helper body");

        assert!(
            !body.contains("Vec::<String>::with_capacity(DECODED_CANDIDATE_LIMIT)"),
            "embedded provider follow-up should not preallocate decoded values before a usable decoded candidate"
        );
        assert!(
            !body.contains("DecodedCandidateIndex::with_capacity(DECODED_CANDIDATE_LIMIT)"),
            "embedded provider follow-up should not preallocate decoded dedup index before a usable decoded candidate"
        );
        assert!(
            body.contains("DecodedCandidateStorage::default()"),
            "embedded provider follow-up should share lazy decoded candidate storage"
        );
        assert_eq!(
            provider_followup_urls_from_embedded_base64(
                "plain page without embedded provider candidates",
                "https://example.com/page.html",
            ),
            None
        );
    }

    #[test]
    fn test_fetch_candidate_merges_inline_and_provider_proxies() {
        let source = SourceInput {
            id: "mixed-provider".into(),
            label: "Mixed Provider".into(),
            seed: "https://mixed.example.com/config.yaml".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://mixed.example.com/config.yaml".into(),
            &source,
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetcher = |_input: &FreeNodesInput,
                       _source: &CandidateSource,
                       url: &str,
                       _timeout: u64,
                       _agent_cache: &mut AgentCache| {
            if url.ends_with("/config.yaml") {
                Ok(
                    "proxies:\n  - name: inline-node\n    type: ss\n    server: inline.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\nproxy-providers:\n  daily:\n    type: http\n    url: ./providers/daily.yaml\n"
                        .to_string(),
                )
            } else {
                Ok(
                    "proxies:\n  - name: provider-node\n    type: ss\n    server: provider.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        let names = proxies
            .iter()
            .filter_map(|proxy| proxy.proxy.get("name").and_then(string_value))
            .collect::<Vec<_>>();
        assert_eq!(names, vec!["inline-node", "provider-node"]);
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 2);
    }

    #[test]
    fn test_fetch_candidate_tries_github_mirrors_for_provider_followup() {
        let source = SourceInput {
            id: "github-provider".into(),
            label: "GitHub Provider".into(),
            seed: "https://mixed.example.com/config.yaml".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://mixed.example.com/config.yaml".into(),
            &source,
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let raw_provider = "https://raw.githubusercontent.com/owner/repo/main/providers/daily.yaml";
        let mirrored_provider = first_github_mirror_url(raw_provider).expect("first raw mirror");
        let mirrored_provider_for_fetcher = mirrored_provider.clone();
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.yaml") {
                Ok(format!(
                    "proxy-providers:\n  daily:\n    type: http\n    url: {raw_provider}\n"
                ))
            } else if url == mirrored_provider_for_fetcher {
                Ok(
                    "proxies:\n  - name: mirrored-provider-node\n    type: ss\n    server: mirrored.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            } else {
                Err("raw github blocked".to_string())
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(
            proxies
                .iter()
                .filter_map(|proxy| proxy.proxy.get("name").and_then(string_value))
                .collect::<Vec<_>>(),
            vec!["mirrored-provider-node"]
        );
        let fetched_urls = fetched_urls.lock().unwrap();
        assert_eq!(
            fetched_urls.get(1).map(String::as_str),
            Some(mirrored_provider.as_str())
        );
        assert!(!fetched_urls.iter().any(|url| url == raw_provider));
        assert_eq!(statuses.len(), 1);
        assert!(statuses[0].success);
        assert_eq!(statuses[0].proxy_count, 1);
    }

    #[test]
    fn test_github_mirror_fetch_loop_is_shared() {
        let source = include_str!("free_nodes.rs");
        let provider_body = source
            .split("fn fetch_provider_followup_text_with_fetcher")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_provider_followup_urls").next())
            .expect("provider follow-up fetch body");
        let discovery_body = source
            .split("fn fetch_discovery_page_text_with_fetcher")
            .nth(1)
            .and_then(|rest| rest.split("fn fetch_github_mirrorable_text_with").next())
            .expect("discovery page fetch body");

        assert!(source.contains("fn fetch_github_mirrorable_text_with"));
        assert!(
            provider_body.contains("fetch_github_mirrorable_text_with(url"),
            "provider follow-up should reuse the shared GitHub mirror fetch helper"
        );
        assert!(
            discovery_body.contains("fetch_github_mirrorable_text_with(url"),
            "discovery page fetch should reuse the shared GitHub mirror fetch helper"
        );
        assert!(
            !provider_body.contains("for mirror_index in 0..GITHUB_RAW_MIRROR_PREFIXES.len()"),
            "provider follow-up must not duplicate the mirror retry loop"
        );
        assert!(
            !discovery_body.contains("for mirror_index in 0..GITHUB_RAW_MIRROR_PREFIXES.len()"),
            "discovery page fetch must not duplicate the mirror retry loop"
        );
    }

    #[test]
    fn test_github_mirror_fetch_loop_tries_raw_mirrors_before_path() {
        let raw_provider = "https://raw.githubusercontent.com/owner/repo/main/providers/daily.yaml";
        let first_raw_provider = first_github_mirror_url(raw_provider).expect("first raw mirror");
        let mut fetched_urls = Vec::new();

        let text = fetch_github_mirrorable_text_with(raw_provider, |url| {
            fetched_urls.push(url.to_string());
            if url == first_raw_provider {
                Ok("proxies: []".to_string())
            } else {
                Err("blocked".to_string())
            }
        })
        .expect("raw mirror should satisfy GitHub follow-up fetch");

        assert_eq!(text, "proxies: []");
        assert_eq!(
            fetched_urls.first().map(String::as_str),
            Some(first_raw_provider.as_str())
        );
        assert!(fetched_urls.iter().any(|url| url == &first_raw_provider));
        assert!(!fetched_urls.iter().any(|url| url == raw_provider));
    }

    #[test]
    fn test_github_mirror_fetch_loop_tries_path_mirrors_before_secondary_raw_proxies() {
        let raw_provider = "https://raw.githubusercontent.com/owner/repo/main/providers/daily.yaml";
        let first_raw_provider = first_github_mirror_url(raw_provider).expect("first raw mirror");
        let first_path_provider =
            nth_github_path_mirror_url(raw_provider, 0).expect("first path mirror");
        let secondary_raw_provider =
            nth_github_mirror_url(raw_provider, 1).expect("secondary raw mirror");
        let mut fetched_urls = Vec::new();

        let text = fetch_github_mirrorable_text_with(raw_provider, |url| {
            fetched_urls.push(url.to_string());
            if url == first_path_provider {
                Ok("proxies: []".to_string())
            } else {
                Err("blocked".to_string())
            }
        })
        .expect("path mirror should satisfy GitHub follow-up fetch");

        assert_eq!(text, "proxies: []");
        assert_eq!(
            fetched_urls.first().map(String::as_str),
            Some(first_raw_provider.as_str())
        );
        assert_eq!(
            fetched_urls.get(1).map(String::as_str),
            Some(first_path_provider.as_str())
        );
        assert!(!fetched_urls
            .iter()
            .any(|url| url == &secondary_raw_provider));
    }

    #[test]
    fn test_github_mirror_fetch_loop_prefilters_plain_urls_before_canonical_fetch_key() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn fetch_github_mirrorable_text_with")
            .and_then(|(_, rest)| rest.split_once("fn deduplicate_discovery_page_queue"))
            .map(|(body, _)| body)
            .expect("fetch_github_mirrorable_text_with body");
        let hint_index = body
            .find("has_github_fetch_key_canonical_hint(url)")
            .expect("canonical hint prefilter");
        let canonical_index = body
            .find("canonical_fetch_key(url)")
            .expect("canonical fetch key");
        let mut fetched_urls = Vec::new();

        let text =
            fetch_github_mirrorable_text_with("https://example.com/providers/daily.yaml", |url| {
                fetched_urls.push(url.to_string());
                Ok("proxies: []".to_string())
            })
            .expect("plain URL should fetch directly");

        assert!(hint_index < canonical_index);
        assert_eq!(text, "proxies: []");
        assert_eq!(
            fetched_urls,
            vec!["https://example.com/providers/daily.yaml"]
        );
    }

    #[test]
    fn test_github_mirror_fetch_loop_avoids_reparsing_canonical_fetch_key() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn fetch_github_mirrorable_text_with")
            .and_then(|(_, rest)| rest.split_once("fn deduplicate_discovery_page_queue"))
            .map(|(body, _)| body)
            .expect("fetch_github_mirrorable_text_with body");

        assert!(
            body.contains("let fetch_key = canonical_fetch_key(url);"),
            "GitHub mirror fetch should still canonicalize mirrors before retry"
        );
        assert!(
            !body.contains("is_github_mirrorable_url(&fetch_key)"),
            "GitHub mirror fetch should not parse the canonical fetch key a second time"
        );
    }

    #[test]
    fn test_github_mirror_fetch_loop_reuses_path_mirror_suffix() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn fetch_github_mirrorable_text_with")
            .and_then(|(_, rest)| rest.split_once("fn deduplicate_discovery_page_queue"))
            .map(|(body, _)| body)
            .expect("fetch_github_mirrorable_text_with body");

        assert!(
            body.contains("let Some(path_mirror_suffix) = github_path_mirror_suffix(&fetch_key)"),
            "GitHub mirror fetch should parse the path mirror suffix once"
        );
        assert!(
            body.contains("for prefix in GITHUB_PATH_MIRROR_PREFIXES"),
            "GitHub mirror fetch should build path mirrors from the cached suffix"
        );
        assert!(
            !body.contains("nth_github_path_mirror_url(&fetch_key"),
            "GitHub mirror fetch should not parse the same raw fetch key once per path mirror"
        );
    }

    #[test]
    fn test_github_mirror_fetch_loop_iterates_raw_mirror_prefixes_without_index_option() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split_once("fn fetch_github_mirrorable_text_with")
            .and_then(|(_, rest)| rest.split_once("fn deduplicate_discovery_page_queue"))
            .map(|(body, _)| body)
            .expect("fetch_github_mirrorable_text_with body");

        assert!(
            body.contains("GITHUB_RAW_MIRROR_PREFIXES.split_first()"),
            "GitHub mirror fetch should split the first raw mirror from secondary fallbacks"
        );
        assert!(
            body.contains("for prefix in remaining_raw_prefixes"),
            "GitHub mirror fetch should iterate remaining raw mirror prefixes directly"
        );
        assert!(
            !body.contains("for mirror_index in 0..GITHUB_RAW_MIRROR_PREFIXES.len()"),
            "GitHub mirror fetch should avoid index bounds in the raw mirror loop"
        );
        assert!(
            !body.contains("nth_github_mirror_url(&fetch_key, mirror_index)"),
            "GitHub mirror fetch should avoid Option-returning indexed helpers"
        );
    }

    #[test]
    fn test_provider_followup_urls_prioritize_structured_provider_urls() {
        let urls = discover_provider_followup_urls(
            "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nproxy-providers:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n",
            "https://mixed.example.com/config.yaml",
        );

        assert_eq!(
            urls,
            vec!["https://mixed.example.com/providers/daily.yaml?target=clash"]
        );
    }

    #[test]
    fn test_provider_followup_urls_prioritize_case_variant_provider_keys() {
        let urls = discover_provider_followup_urls(
            "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nProxy-Providers:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n",
            "https://mixed.example.com/config.yaml",
        );

        assert_eq!(
            urls,
            vec!["https://mixed.example.com/providers/daily.yaml?target=clash"]
        );
    }

    #[test]
    fn test_provider_followup_urls_prioritize_case_variant_provider_url_fields() {
        let urls = discover_provider_followup_urls(
            "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nproxy-providers:\n  daily:\n    type: http\n    URL: ./providers/daily.yaml?target=clash\n",
            "https://mixed.example.com/config.yaml",
        );

        assert_eq!(
            urls,
            vec!["https://mixed.example.com/providers/daily.yaml?target=clash"]
        );
    }

    #[test]
    fn test_provider_followup_urls_prioritize_generic_providers_key() {
        let urls = discover_provider_followup_urls(
            "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nproviders:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n",
            "https://mixed.example.com/config.yaml",
        );

        assert_eq!(
            urls,
            vec!["https://mixed.example.com/providers/daily.yaml?target=clash"]
        );
    }

    #[test]
    fn test_provider_followup_urls_prioritize_generic_provider_key() {
        let urls = discover_provider_followup_urls(
            "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nprovider:\n  type: http\n  url: ./providers/daily.yaml?target=clash\n",
            "https://mixed.example.com/config.yaml",
        );

        assert_eq!(
            urls,
            vec!["https://mixed.example.com/providers/daily.yaml?target=clash"]
        );
    }

    #[test]
    fn test_provider_followup_urls_follow_relative_provider_path_without_url() {
        let urls = discover_provider_followup_urls(
            "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nproxy-providers:\n  daily:\n    type: file\n    path: ./providers/daily.yaml\n",
            "https://mixed.example.com/config.yaml",
        );

        assert_eq!(urls, vec!["https://mixed.example.com/providers/daily.yaml"]);
    }

    #[test]
    fn test_provider_followup_urls_prioritize_singular_provider_urls() {
        let urls = discover_provider_followup_urls(
            "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nproxy-provider:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n",
            "https://mixed.example.com/config.yaml",
        );

        assert_eq!(
            urls,
            vec!["https://mixed.example.com/providers/daily.yaml?target=clash"]
        );
    }

    #[test]
    fn test_discover_provider_followup_urls_preallocates_provider_results() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn discover_provider_followup_urls")
            .nth(1)
            .and_then(|rest| {
                rest.split("fn extract_yaml_proxy_provider_url_values")
                    .next()
            })
            .expect("discover_provider_followup_urls body");

        assert!(
            body.contains("let provider_urls = extract_yaml_proxy_provider_url_values(text);"),
            "provider URLs should be extracted once so their count can size discovery containers"
        );
        assert!(
            body.contains("Vec::<String>::with_capacity(provider_urls.len())"),
            "provider follow-up results should preallocate to the extracted provider URL count"
        );
        assert!(
            body.contains("DiscoveredUrlIndex::with_capacity(provider_urls.len())"),
            "provider follow-up dedup index should preallocate to the extracted provider URL count"
        );
        assert!(
            !body
                .split("let provider_urls = extract_yaml_proxy_provider_url_values(text);")
                .next()
                .unwrap_or_default()
                .contains("Vec::<String>::new()"),
            "provider follow-up discovery should not allocate an empty result before provider count is known"
        );
    }

    #[test]
    fn test_first_yaml_key_value_uses_exact_match_before_case_fallback() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn first_yaml_key_value")
            .nth(1)
            .and_then(|rest| rest.split("fn push_yaml_proxy_provider_url_value").next())
            .expect("first_yaml_key_value body");

        let exact_index = body.find("object.get(*key)").expect("exact key lookup");
        let fallback_index = body
            .find("eq_ignore_ascii_case")
            .expect("case-insensitive fallback");
        assert!(
            exact_index < fallback_index,
            "provider key lookup should preserve the exact-key hot path before case-insensitive fallback"
        );

        let object = serde_json::json!({ "Proxy-Providers": [] })
            .as_object()
            .cloned()
            .expect("object");
        assert!(first_yaml_key_value(&object, &YAML_PROXY_PROVIDER_KEYS).is_some());

        let provider = serde_json::json!({ "URL": "./providers/daily.yaml" })
            .as_object()
            .cloned()
            .expect("provider object");
        assert_eq!(
            first_yaml_key_value(&provider, &["url"])
                .and_then(string_value)
                .as_deref(),
            Some("./providers/daily.yaml")
        );
    }

    #[test]
    fn test_provider_url_field_lookup_reuses_exact_first_helper() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn push_yaml_proxy_provider_url_value")
            .nth(1)
            .and_then(|rest| rest.split("const PROVIDER_FOLLOWUP_HINTS").next())
            .expect("provider URL value body");

        assert!(
            body.contains("first_yaml_key_value(provider, &[\"url\"])"),
            "provider URL field lookup should preserve exact-key lookup with case-insensitive fallback"
        );
        assert!(
            !body.contains("provider.get(\"url\")"),
            "provider URL field lookup should not silently ignore URL/Url variants"
        );
    }

    #[test]
    fn test_fetch_candidate_uses_structured_provider_urls_before_probe_urls() {
        let source = SourceInput {
            id: "ordered-provider".into(),
            label: "Ordered Provider".into(),
            seed: "https://ordered.example.com/config.yaml".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let candidate = ConfigCandidate::from_source_ref(
            "https://ordered.example.com/config.yaml".into(),
            &source,
        );
        let mut proxies = Vec::<DatedProxy>::new();
        let mut statuses = Vec::<SourceStatus>::new();
        let fetched_urls = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls_ref = Arc::clone(&fetched_urls);
        let fetcher = move |_input: &FreeNodesInput,
                            _source: &CandidateSource,
                            url: &str,
                            _timeout: u64,
                            _agent_cache: &mut AgentCache| {
            fetched_urls_ref.lock().unwrap().push(url.to_string());
            if url.ends_with("/config.yaml") {
                Ok(
                    "proxy-groups:\n  - name: AUTO\n    type: url-test\n    url: https://probe.example.com/health.yaml\nproxy-providers:\n  daily:\n    type: http\n    url: ./providers/daily.yaml?target=clash\n"
                        .to_string(),
                )
            } else if url.contains("/providers/daily.yaml") {
                Ok(
                    "proxies:\n  - name: ordered-provider-node\n    type: ss\n    server: ordered.example.com\n    port: 443\n    cipher: aes-128-gcm\n    password: pass\n"
                        .to_string(),
                )
            } else {
                panic!("unexpected provider follow-up fetch: {url}");
            }
        };
        let mut agent_cache = AgentCache::default();

        assert!(fetch_candidate_with_fetcher(
            &input,
            candidate,
            &mut proxies,
            &mut statuses,
            &mut agent_cache,
            &fetcher,
        ));

        assert_eq!(
            *fetched_urls.lock().unwrap(),
            vec![
                "https://ordered.example.com/config.yaml".to_string(),
                "https://ordered.example.com/providers/daily.yaml?target=clash".to_string(),
            ]
        );
        assert_eq!(proxies.len(), 1);
        assert_eq!(
            proxies[0]
                .proxy
                .get("name")
                .and_then(string_value)
                .as_deref(),
            Some("ordered-provider-node")
        );
    }

    #[test]
    fn test_resolve_candidates_keeps_more_sources() {
        let raw_candidates = (0..180)
            .map(|index| format!("https://bulk.example.com/{index}.yaml"))
            .collect::<Vec<_>>();
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![SourceInput {
                    id: "bulk".into(),
                    label: "Bulk".into(),
                    seed: "https://bulk.example.com/".into(),
                    rank: 0,
                    update_interval_hours: 24,
                    page_discovery: false,
                    github_discovery: false,
                    raw_candidates,
                    candidate_urls: vec![],
                }],
            },
            enabled_source_ids: vec!["bulk".into()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 8,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };

        let candidates = resolve_candidates(&input);

        assert!(candidates.len() >= 180);
    }

    #[test]
    fn test_resolve_candidates_preserves_github_canonical_coverage_with_bounded_fallbacks() {
        let raw_candidates = (0..100)
            .map(|index| {
                format!("https://raw.githubusercontent.com/owner/repo/main/subs/{index:03}.yaml")
            })
            .collect::<Vec<_>>();
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![SourceInput {
                    id: "github".into(),
                    label: "GitHub".into(),
                    seed: "https://github.com/owner/repo".into(),
                    rank: 0,
                    update_interval_hours: 24,
                    page_discovery: false,
                    github_discovery: false,
                    raw_candidates,
                    candidate_urls: vec![],
                }],
            },
            enabled_source_ids: vec!["github".into()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 8,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };

        let candidates = resolve_candidates(&input);
        let canonical_count = candidates
            .iter()
            .map(|candidate| canonical_fetch_key(&candidate.url))
            .collect::<HashSet<_>>()
            .len();

        assert_eq!(canonical_count, 100);
        assert_eq!(candidates.len(), CONFIG_CANDIDATE_LIMIT);
        assert!(candidates
            .iter()
            .any(|candidate| candidate.url.starts_with("https://ghfile.geekertao.top/")));
        assert!(candidates
            .iter()
            .any(|candidate| candidate.url.starts_with("https://gh-proxy.com/")));
        assert!(candidates.iter().any(|candidate| candidate
            .url
            .starts_with("https://raw.githubusercontent.com/")));
        assert!(candidates.iter().any(|candidate| candidate
            .url
            .starts_with("https://rawgithubusercontent.deno.dev/")));
    }

    #[test]
    fn test_config_candidate_limit_scales_with_equivalent_github_mirrors() {
        assert_eq!(
            CONFIG_CANDIDATE_LIMIT,
            MAX_EQUIVALENT_FETCH_CANDIDATES * 100
        );
    }

    #[test]
    fn test_resolve_candidates_keeps_non_github_sources_before_mirror_fallbacks() {
        let github_raw_candidates = (0..100)
            .map(|index| {
                format!("https://raw.githubusercontent.com/owner/repo/main/subs/{index:03}.yaml")
            })
            .collect::<Vec<_>>();
        let web_raw_candidates = (0..20)
            .map(|index| format!("https://web.example.com/daily/{index:03}.yaml"))
            .collect::<Vec<_>>();
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![
                    SourceInput {
                        id: "github".into(),
                        label: "GitHub".into(),
                        seed: "https://github.com/owner/repo".into(),
                        rank: 0,
                        update_interval_hours: 24,
                        page_discovery: false,
                        github_discovery: false,
                        raw_candidates: github_raw_candidates,
                        candidate_urls: vec![],
                    },
                    SourceInput {
                        id: "web".into(),
                        label: "Web".into(),
                        seed: "https://web.example.com/".into(),
                        rank: 99,
                        update_interval_hours: 24,
                        page_discovery: false,
                        github_discovery: false,
                        raw_candidates: web_raw_candidates,
                        candidate_urls: vec![],
                    },
                ],
            },
            enabled_source_ids: vec!["github".into(), "web".into()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 8,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };

        let candidates = resolve_candidates(&input);

        assert!(candidates
            .iter()
            .any(|candidate| candidate.url.starts_with("https://web.example.com/")));
    }

    #[test]
    fn test_add_config_or_page_allows_same_host_subscription_javascript_only() {
        let source = SourceInput {
            id: "page".into(),
            label: "Page".into(),
            seed: "https://site.example.com/free-node/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let source = Arc::new(CandidateSource::from_source(&source));
        let mut configs = HashMap::<String, Arc<CandidateSource>>::new();
        let mut page_queue = VecDeque::<ConfigCandidate>::new();
        let mut visited_pages = HashSet::<String>::new();
        let mut visited_page_fetch_keys = HashSet::<String>::new();

        add_config_or_page(
            &mut configs,
            &mut page_queue,
            &mut visited_pages,
            &mut visited_page_fetch_keys,
            "https://site.example.com/assets/free-nodes.js",
            &source,
        );
        add_config_or_page(
            &mut configs,
            &mut page_queue,
            &mut visited_pages,
            &mut visited_page_fetch_keys,
            "https://site.example.com/assets/app.js",
            &source,
        );
        add_config_or_page(
            &mut configs,
            &mut page_queue,
            &mut visited_pages,
            &mut visited_page_fetch_keys,
            "https://cdn.example.com/assets/free-nodes.js",
            &source,
        );

        assert_eq!(page_queue.len(), 1);
        assert_eq!(
            page_queue.front().map(|candidate| candidate.url.as_str()),
            Some("https://site.example.com/assets/free-nodes.js")
        );
    }

    #[test]
    fn test_discovery_page_limit_scales_with_page_source_count() {
        let page_queue = (0..29)
            .map(|index| {
                ConfigCandidate::from_source_ref(
                    format!("https://page-{index}.example.com/free-node/"),
                    &SourceInput {
                        id: format!("page-{index}"),
                        label: format!("Page {index}"),
                        seed: format!("https://page-{index}.example.com/free-node/"),
                        rank: index,
                        update_interval_hours: 24,
                        page_discovery: true,
                        github_discovery: false,
                        raw_candidates: vec![],
                        candidate_urls: vec![],
                    },
                )
            })
            .collect::<VecDeque<_>>();

        assert_eq!(
            discovery_page_limit(DISCOVERY_CONFIG_THRESHOLD, &page_queue),
            87
        );
    }

    #[test]
    fn test_discovery_page_limit_preallocates_source_count_set() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn discovery_page_limit(")
            .nth(1)
            .and_then(|rest| rest.split("fn discover_pages_parallel").next())
            .expect("discovery_page_limit body");

        assert!(
            body.contains("HashSet::<&str>::with_capacity(page_queue.len())"),
            "discovery_page_limit should preallocate source id tracking"
        );
        assert!(
            !body.contains(".collect::<HashSet<_>>()"),
            "discovery_page_limit should avoid collect-driven HashSet growth"
        );
    }

    #[test]
    fn test_parallel_page_discovery_adds_config_candidates() {
        let source = SourceInput {
            id: "page".into(),
            label: "Page".into(),
            seed: "https://page.example.com/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec!["page".into()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 4,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let pages = VecDeque::from([
            ConfigCandidate::from_source_ref("https://page.example.com/a/".into(), &source),
            ConfigCandidate::from_source_ref("https://page.example.com/b/".into(), &source),
        ]);

        let configs = discover_pages_with_fetcher(
            &input,
            HashMap::new(),
            pages,
            HashSet::new(),
            2,
            &|_, _, url, _| {
                Ok(if url.ends_with("/a/") {
                    r#"<a href="a.yaml">a</a>"#.to_string()
                } else {
                    r#"<a href="https://page.example.com/b.yaml">b</a>"#.to_string()
                })
            },
        );

        assert!(configs.contains_key("https://page.example.com/a/a.yaml"));
        assert!(configs.contains_key("https://page.example.com/b.yaml"));
    }

    #[test]
    fn test_parallel_page_discovery_fetches_canonical_duplicate_pages_once() {
        let source = SourceInput {
            id: "github-page".into(),
            label: "GitHub Page".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 2,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let raw_page = "https://raw.githubusercontent.com/owner/repo/main/README.md";
        let mirror_page =
            "https://gh.llkk.cc/https://raw.githubusercontent.com/owner/repo/main/README.md";
        let pages = VecDeque::from([
            ConfigCandidate::from_source_ref(mirror_page.into(), &source),
            ConfigCandidate::from_source_ref(raw_page.into(), &source),
        ]);
        let fetched = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls = Arc::clone(&fetched);

        let configs = discover_pages_with_fetcher(
            &input,
            HashMap::new(),
            pages,
            HashSet::new(),
            4,
            &|_, _, url, _| {
                fetched_urls.lock().unwrap().push(url.to_string());
                Ok(r#"<a href="https://raw.githubusercontent.com/owner/repo/main/subs/free.yaml">free</a>"#
                    .to_string())
            },
        );

        let fetched = fetched.lock().unwrap();
        assert_eq!(fetched.len(), 1);
        assert_eq!(
            canonical_fetch_key(&fetched[0]),
            canonical_fetch_key(raw_page)
        );
        assert!(configs
            .contains_key("https://raw.githubusercontent.com/owner/repo/main/subs/free.yaml"));
    }

    #[test]
    fn test_parallel_page_discovery_tries_github_mirrors_for_api_pages() {
        let source = SourceInput {
            id: "github-api-page".into(),
            label: "GitHub API Page".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let api_page = "https://api.github.com/repos/owner/repo/contents?ref=main";
        let canonical_api_page = "https://api.github.com/repos/owner/repo/contents";
        let mirrored_api_page = format!("https://gh.llkk.cc/{canonical_api_page}");
        let pages = VecDeque::from([ConfigCandidate::from_source_ref(api_page.into(), &source)]);
        let fetched = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls = Arc::clone(&fetched);
        let mirrored_api_page_for_fetcher = mirrored_api_page.clone();

        let configs = discover_pages_with_fetcher(
            &input,
            HashMap::new(),
            pages,
            HashSet::new(),
            1,
            &|_, _, url, _| {
                fetched_urls.lock().unwrap().push(url.to_string());
                if url == mirrored_api_page_for_fetcher {
                    Ok(
                        r#"[{"path":"configs/free.yaml","type":"file","download_url":null}]"#
                            .to_string(),
                    )
                } else {
                    Err("github api blocked".to_string())
                }
            },
        );

        let fetched = fetched.lock().unwrap();
        assert_eq!(
            fetched.first().map(String::as_str),
            Some(mirrored_api_page.as_str())
        );
        assert!(!fetched.iter().any(|url| url == api_page));
        assert!(!fetched.iter().any(|url| url == canonical_api_page));
        assert!(configs
            .contains_key("https://raw.githubusercontent.com/owner/repo/main/configs/free.yaml"));
    }

    #[test]
    fn test_github_page_discovery_follows_readme_markdown_subscription_links() {
        let source = SourceInput {
            id: "github-readme".into(),
            label: "GitHub README".into(),
            seed: "https://github.com/owner/repo".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: false,
            github_discovery: true,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec![source.id.clone()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let api_page = "https://api.github.com/repos/owner/repo/contents?ref=main";
        let pages = VecDeque::from([ConfigCandidate::from_source_ref(api_page.into(), &source)]);
        let fetched = Arc::new(Mutex::new(Vec::<String>::new()));
        let fetched_urls = Arc::clone(&fetched);

        let configs = discover_pages_with_fetcher(
            &input,
            HashMap::new(),
            pages,
            HashSet::new(),
            3,
            &|_, _, url, _| {
                fetched_urls.lock().unwrap().push(url.to_string());
                let key = canonical_fetch_key(url);
                if key == "https://api.github.com/repos/owner/repo/contents" {
                    Ok(r#"[{"path":"README.md","type":"file","download_url":null}]"#.to_string())
                } else if key == "https://raw.githubusercontent.com/owner/repo/main/README.md" {
                    Ok("[Clash subscription](subs/free.yaml?target=clash)".to_string())
                } else {
                    Err("unexpected url".to_string())
                }
            },
        );

        assert!(fetched
            .lock()
            .unwrap()
            .iter()
            .any(|url| canonical_fetch_key(url)
                == "https://raw.githubusercontent.com/owner/repo/main/README.md"));
        assert!(configs.contains_key(
            "https://raw.githubusercontent.com/owner/repo/main/subs/free.yaml?target=clash"
        ));
    }

    #[test]
    fn test_discover_urls_reads_github_tree_paths_as_raw_candidates() {
        let text = r#"{
          "tree": [
            {"path": "README.md", "type": "blob"},
            {"path": "docs/guide.md", "type": "blob"},
            {"path": "subs/clash.yml", "type": "blob"},
            {"path": "subs/list.txt", "type": "blob"},
            {"path": "static/sub_zh", "type": "blob"},
            {"path": "v2ray", "type": "blob"},
            {"path": "image.png", "type": "blob"}
          ]
        }"#;

        let urls = discover_urls(
            text,
            "https://api.github.com/repos/owner/repo/git/trees/main?recursive=1",
        );

        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/subs/clash.yml".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/subs/list.txt".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/static/sub_zh".to_string()
        ));
        assert!(
            urls.contains(&"https://raw.githubusercontent.com/owner/repo/main/v2ray".to_string())
        );
        assert!(urls
            .contains(&"https://raw.githubusercontent.com/owner/repo/main/README.md".to_string()));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/docs/guide.md".to_string()
        ));
        assert!(!urls
            .contains(&"https://raw.githubusercontent.com/owner/repo/main/image.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_protocol_split_json_proxy_lists_from_github_tree() {
        let text = r#"{
          "tree": [
            {"path": "proxies/protocols/http/data.json", "type": "blob"},
            {"path": "proxies/protocols/http/data.txt", "type": "blob"},
            {"path": "proxies/protocols/http/data.csv", "type": "blob"},
            {"path": "proxies/protocols/socks4/data.json", "type": "blob"},
            {"path": "proxies/protocols/socks4/data.txt", "type": "blob"},
            {"path": "proxies/protocols/socks4/data.csv", "type": "blob"},
            {"path": "proxies/protocols/socks5/data.json", "type": "blob"},
            {"path": "proxies/protocols/socks5/data.txt", "type": "blob"},
            {"path": "proxies/protocols/socks5/data.csv", "type": "blob"},
            {"path": "proxies/all/data.json", "type": "blob"},
            {"path": "proxies/all/data.txt", "type": "blob"},
            {"path": "proxies/all/data.csv", "type": "blob"},
            {"path": "online-proxies/txt/proxies.txt", "type": "blob"},
            {"path": "online-proxies/txt/proxies-http.txt", "type": "blob"},
            {"path": "online-proxies/txt/proxies-socks4.txt", "type": "blob"},
            {"path": "online-proxies/csv/proxies.csv", "type": "blob"},
            {"path": "online-proxies/json/proxies-basic.json", "type": "blob"},
            {"path": "online-proxies/yaml/proxies-basic.yaml", "type": "blob"},
            {"path": "online-proxies/xml/proxies-basic.xml", "type": "blob"},
            {"path": "all-proxies.txt", "type": "blob"},
            {"path": "http.csv", "type": "blob"},
            {"path": "https.csv", "type": "blob"},
            {"path": "socks5.csv", "type": "blob"},
            {"path": "protocols/http.csv", "type": "blob"},
            {"path": "protocols/https.csv", "type": "blob"},
            {"path": "protocols/socks4.txt", "type": "blob"},
            {"path": "protocols/socks4.csv", "type": "blob"},
            {"path": "protocols/socks5.txt", "type": "blob"},
            {"path": "protocols/socks5.csv", "type": "blob"},
            {"path": "proxylist.csv", "type": "blob"},
            {"path": "proxylist.xml", "type": "blob"},
            {"path": "proxylist.phps", "type": "blob"},
            {"path": "all.csv", "type": "blob"},
            {"path": "free.csv", "type": "blob"},
            {"path": "node.csv", "type": "blob"},
            {"path": "nodes.csv", "type": "blob"},
            {"path": "proxies.csv", "type": "blob"},
            {"path": "proxies.json", "type": "blob"},
            {"path": "proxy.csv", "type": "blob"},
            {"path": "nodes.json", "type": "blob"},
            {"path": "proxy.json", "type": "blob"},
            {"path": "all.json", "type": "blob"},
            {"path": "free.json", "type": "blob"},
            {"path": "proxy-list.csv", "type": "blob"},
            {"path": "proxy-list.json", "type": "blob"},
            {"path": "proxylist.yaml", "type": "blob"},
            {"path": "proxy-list.yml", "type": "blob"},
            {"path": "providers.yaml", "type": "blob"},
            {"path": "providers.json", "type": "blob"},
            {"path": "providers/daily.json", "type": "blob"},
            {"path": "provider/free.json", "type": "blob"},
            {"path": "proxy-providers.yaml", "type": "blob"},
            {"path": "proxy-providers.json", "type": "blob"},
            {"path": "proxy-providers/free.json", "type": "blob"},
            {"path": "proxy_providers.json", "type": "blob"},
            {"path": "proxy_providers/free.json", "type": "blob"},
            {"path": "proxy-list-raw.txt", "type": "blob"},
            {"path": "archive/csv/proxies.csv", "type": "blob"},
            {"path": "metadata/data.json", "type": "blob"},
            {"path": "metadata/data.csv", "type": "blob"}
          ]
        }"#;

        let urls = discover_urls(
            text,
            "https://api.github.com/repos/owner/repo/git/trees/main?recursive=1",
        );

        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/http/data.json"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/http/data.txt"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/http/data.csv"
                .to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/socks4/data.json"
                .to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/socks4/data.txt"
                .to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/socks4/data.csv"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/socks5/data.json"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/socks5/data.txt"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/protocols/socks5/data.csv"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/all/data.json".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/all/data.txt".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxies/all/data.csv".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/online-proxies/txt/proxies.txt"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/online-proxies/txt/proxies-http.txt"
                .to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/online-proxies/txt/proxies-socks4.txt"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/online-proxies/csv/proxies.csv"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/online-proxies/json/proxies-basic.json"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/online-proxies/yaml/proxies-basic.yaml"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/online-proxies/xml/proxies-basic.xml"
                .to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/all-proxies.txt".to_string()
        ));
        for path in [
            "http.csv",
            "https.csv",
            "socks5.csv",
            "protocols/http.csv",
            "protocols/https.csv",
            "protocols/socks5.csv",
        ] {
            assert!(
                urls.contains(&format!(
                    "https://raw.githubusercontent.com/owner/repo/main/{path}"
                )),
                "missing GitHub protocol CSV path {path}"
            );
        }
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/protocols/socks4.txt".to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/protocols/socks4.csv".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/protocols/socks5.txt".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxylist.csv".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxylist.xml".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxylist.phps".to_string()
        ));
        for path in [
            "all.csv",
            "free.csv",
            "node.csv",
            "nodes.csv",
            "proxies.csv",
            "proxies.json",
            "proxy.csv",
            "nodes.json",
            "proxy.json",
            "all.json",
            "free.json",
            "proxy-list.csv",
            "proxy-list.json",
            "proxylist.yaml",
            "proxy-list.yml",
            "providers.yaml",
            "providers.json",
            "providers/daily.json",
            "provider/free.json",
            "proxy-providers.yaml",
            "proxy-providers.json",
            "proxy-providers/free.json",
            "proxy_providers.json",
            "proxy_providers/free.json",
        ] {
            assert!(
                urls.contains(&format!(
                    "https://raw.githubusercontent.com/owner/repo/main/{path}"
                )),
                "missing supported root proxy data path {path}"
            );
        }
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/proxy-list-raw.txt".to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/archive/csv/proxies.csv"
                .to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/metadata/data.json".to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/metadata/data.csv".to_string()
        ));
    }

    #[test]
    fn test_github_api_config_path_inlines_extensionless_subscription_names() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn is_github_api_config_path")
            .nth(1)
            .and_then(|rest| rest.split("fn for_each_absolute_url").next())
            .expect("is_github_api_config_path body");

        assert!(
            !body.contains("has_extensionless_subscription_file_name"),
            "extensionless GitHub API subscription path matching should stay in the GitHub API path predicate"
        );
        assert!(
            body.contains("GITHUB_RAW_SEED_PATHS.contains(&file_name)"),
            "GitHub API config path matching should reuse the raw seed path table for extensionless basenames"
        );
        assert!(
            body.contains("has_config_extension_in_path(path)"),
            "GitHub API config path matching should keep the normal config extension fast path"
        );
        for path in ["node", "nodes", "proxy", "proxies", "profile", "profiles"] {
            assert!(
                is_github_api_config_path(path),
                "GitHub API config path should accept extensionless {path}"
            );
            assert!(
                is_github_api_config_path(&format!("nested/{path}")),
                "GitHub API config path should accept nested extensionless {path}"
            );
        }
    }

    #[test]
    fn test_has_config_extension_in_path_keeps_compact_suffix_loop() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn has_config_extension_in_path")
            .nth(1)
            .and_then(|rest| rest.split("fn is_page_candidate").next())
            .expect("has_config_extension_in_path body");
        let compact_body = body.split_whitespace().collect::<String>();

        assert!(
            body.contains("[\".yaml\", \".yml\", \".txt\", \".json\"]"),
            "config extension checks should keep the compact suffix table"
        );
        assert!(
            compact_body.contains(".iter().any(|suffix|"),
            "config extension checks should keep the compact suffix loop"
        );
        assert!(
            !body.contains("match bytes.last().map(|byte| byte | 0x20)"),
            "config extension checks should not use the larger final-byte branch form"
        );
    }

    #[test]
    fn test_discover_urls_reads_github_contents_paths_as_raw_candidates() {
        let text = r#"[
          {"path": "README.md", "type": "file", "download_url": null},
          {"path": "docs/guide.md", "type": "file", "download_url": null},
          {"path": "configs/clash.yaml", "type": "file", "download_url": null},
          {"path": "base64/sub.txt", "type": "file", "download_url": null},
          {"path": "assets/icon.svg", "type": "file", "download_url": null}
        ]"#;

        let urls = discover_urls(
            text,
            "https://api.github.com/repos/owner/repo/contents?ref=dev",
        );

        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/dev/configs/clash.yaml".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/dev/base64/sub.txt".to_string()
        ));
        assert!(urls
            .contains(&"https://raw.githubusercontent.com/owner/repo/dev/README.md".to_string()));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/dev/docs/guide.md".to_string()
        ));
        assert!(!urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/dev/assets/icon.svg".to_string()
        ));
    }

    #[test]
    fn test_discover_urls_canonicalizes_duplicate_github_config_forms() {
        let urls = discover_urls(
            r#"
https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yaml
https://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml
https://gh-proxy.com/https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml
"#,
            "https://github.com/PuddinCat/BestClash",
        );

        assert_eq!(
            urls,
            vec!["https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"]
        );
    }

    #[test]
    fn test_discover_urls_splits_concatenated_puddincat_github_config_urls() {
        let urls = discover_urls(
            "https://ghfile.geekertao.top/https://github.com/PuddinCat/BestClash/blob/main/proxies.yamlhttps://raw.githubusercontent.com/PuddinCat/BestClash/refs/heads/main/proxies.yaml",
            "https://github.com/PuddinCat/BestClash",
        );

        assert_eq!(
            urls,
            vec!["https://raw.githubusercontent.com/PuddinCat/BestClash/main/proxies.yaml"]
        );
    }

    #[test]
    fn test_discover_urls_skips_github_contents_file_api_self_urls() {
        let text = r#"[
          {
            "path": "configs",
            "type": "dir",
            "url": "https://api.github.com/repos/owner/repo/contents/configs?ref=dev"
          },
          {
            "path": "configs/clash.yaml",
            "type": "file",
            "url": "https://api.github.com/repos/owner/repo/contents/configs/clash.yaml?ref=dev",
            "download_url": null
          }
        ]"#;

        let urls = discover_urls(
            text,
            "https://api.github.com/repos/owner/repo/contents?ref=dev",
        );

        assert!(urls.contains(
            &"https://api.github.com/repos/owner/repo/contents/configs?ref=dev".to_string()
        ));
        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/dev/configs/clash.yaml".to_string()
        ));
        assert!(!urls.contains(
            &"https://api.github.com/repos/owner/repo/contents/configs/clash.yaml?ref=dev"
                .to_string()
        ));
    }

    #[test]
    fn test_discover_urls_reads_json_escaped_absolute_urls() {
        let text = r#"window.__DATA__ = {
          "subscription": "https:\/\/node.example.com\/uploads\/2026\/06\/0-20260619.yaml?token=a&amp;format=clash"
        };"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://node.example.com/uploads/2026/06/0-20260619.yaml?token=a&format=clash"
                .to_string()
        ));
    }

    #[test]
    fn test_discover_urls_reads_json_unicode_escaped_absolute_urls() {
        let text = r#"window.__DATA__ = {
          "subscription": "https:\u002F\u002Funicode.example.com\u002Ffree\u002Fclash.yaml\u003Ftoken\u003Da\u0026format\u003Dclash",
          "backup": "https\u003A\u002F\u002Fcolon.example.com\u002Fsub\u002Flist.txt\u003Fformat\u003Dclash"
        };"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://unicode.example.com/free/clash.yaml?token=a&format=clash".to_string()
        ));
        assert!(urls.contains(&"https://colon.example.com/sub/list.txt?format=clash".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_html_entity_encoded_absolute_urls() {
        let text = r#"
<a data-sub="https:&#x2F;&#x2F;entity.example.com&#x2F;free&#x2F;clash.yaml&#x3F;token&#x3D;a&#x26;format&#x3D;clash">entity</a>
<button data-url='https&#58;&#47;&#47;decimal.example.com&#47;sub&#47;list.txt&#63;format&#61;clash'>copy</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://entity.example.com/free/clash.yaml?token=a&format=clash".to_string()
        ));
        assert!(urls.contains(&"https://decimal.example.com/sub/list.txt?format=clash".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_named_html_entity_subscription_attributes() {
        let text = r#"
<button data-sub="https&colon;&sol;&sol;named.example.com&sol;daily&sol;clash.yaml&quest;token&equals;a&amp;target&equals;clash">copy</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://named.example.com/daily/clash.yaml?token=a&target=clash".to_string()
        ));
    }

    #[test]
    fn test_discover_urls_reads_standalone_named_html_entity_absolute_urls() {
        let text = r#"
<script>
window.dailySub = "https&colon;&sol;&sol;standalone.example.com&sol;free&sol;daily.yaml&quest;format&equals;clash&amp;token&equals;a";
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://standalone.example.com/free/daily.yaml?format=clash&token=a".to_string()
        ));
    }

    #[test]
    fn test_discover_urls_reads_subscription_urls_from_client_deep_links() {
        let text = r#"
<a href="clash://install-config?url=https%3A%2F%2Fsub.example.com%2Ffree%2Fclash.yaml%3Ftoken%3Da%2520b%26type%3Dclash&name=Daily">Clash</a>
<a href='sing-box://import-remote-profile?url=https%3A%2F%2Fbox.example.com%2Fprofiles%2Fsubscription.txt%3Fformat%3Dsing-box'>Sing-box</a>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://sub.example.com/free/clash.yaml?token=a%20b&type=clash".to_string()
        ));
        assert!(urls.contains(
            &"https://box.example.com/profiles/subscription.txt?format=sing-box".to_string()
        ));
    }

    #[test]
    fn test_discover_urls_prioritizes_contextual_subscription_links() {
        let text = r#"
<a href="https://landing.example.com/news">News</a>
<a href="clash://install-config?url=https%3A%2F%2Fsub.example.com%2Fdaily%2Ffree.yaml%3Ftarget%3Dclash&name=Daily">Clash</a>
https://cdn.example.com/banner.png
"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert_eq!(
            urls.first(),
            Some(&"https://sub.example.com/daily/free.yaml?target=clash".to_string())
        );
        assert!(urls.contains(&"https://landing.example.com/news".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_relative_subscription_urls_from_params() {
        let text = r#"
<a href="clash://install-config?url=%2Fapi%2Fv1%2Fsubscribe%3Ftoken%3Da%26target%3Dclash&name=Daily">Clash</a>
<a href='/install?sub=..%2Fdaily%2Ffree.yaml%3Ftarget%3Dclash'>Daily</a>
<a href="/noop?url=%2Fassets%2Flogo.png">Logo</a>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(
            urls.contains(&"https://example.com/api/v1/subscribe?token=a&target=clash".to_string())
        );
        assert!(urls.contains(&"https://example.com/daily/free.yaml?target=clash".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_keeps_unescaped_subscription_query_params() {
        let text = r#"
<a href="/install?url=/api/v1/subscribe.yaml?token=a&target=clash&name=Daily">Daily</a>
<a href="/jump?sub=https://sub.example.com/free.yaml?token=b&type=clash&label=Copy">Copy</a>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert_eq!(
            urls.first(),
            Some(&"https://example.com/api/v1/subscribe.yaml?token=a&target=clash".to_string())
        );
        assert!(urls.contains(&"https://sub.example.com/free.yaml?token=b&type=clash".to_string()));
        assert!(!urls.contains(&"https://example.com/api/v1/subscribe.yaml?token=a".to_string()));
        assert!(!urls.contains(&"https://sub.example.com/free.yaml?token=b".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_profile_and_client_subscription_params() {
        let text = r#"
<a href="/install?profile=%2Fapi%2Fprofile%2Ffree.yaml%3Ftarget%3Dclash">Profile</a>
<a href="/jump?profile_url=..%2Fdaily%2Fprofile.txt%3Fformat%3Dclash">Profile URL</a>
<a href="/jump?profileUrl=https%3A%2F%2Fprofile.example.com%2Fsub%2Fclash.yaml%3Ftoken%3Da">Profile camel</a>
<a href="/client?clash=api%2Fclash%3Ftoken%3Da">Clash</a>
<a href="/client?v2ray=https%3A%2F%2Fv2ray.example.com%2Fsub.txt%3Fformat%3Dv2ray">V2Ray</a>
<a href="/client?v2ray=assets%2Fbanner.png">Asset</a>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(
            urls.contains(&"https://example.com/api/profile/free.yaml?target=clash".to_string())
        );
        assert!(urls.contains(&"https://example.com/daily/profile.txt?format=clash".to_string()));
        assert!(urls.contains(&"https://profile.example.com/sub/clash.yaml?token=a".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/api/clash?token=a".to_string()));
        assert!(urls.contains(&"https://v2ray.example.com/sub.txt?format=v2ray".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/banner.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_extended_subscription_param_aliases() {
        let text = r#"
<a href="/jump?subscription_url=..%2Fdaily%2Fsubscription.yaml%3Ftarget%3Dclash">Subscription URL</a>
<a href="/jump?subscribe-url=%2Fapi%2Fsubscribe%3Ftoken%3Da%26type%3Dclash">Subscribe URL</a>
<a href="clash://install-config?clash_url=https%3A%2F%2Fclash.example.com%2Fsub.yaml%3Fformat%3Dclash">Clash URL</a>
<a href="/jump?sub_url=https%3A%2F%2Fsub.example.com%2Ffree.txt%3Ftarget%3Dclash">Sub URL</a>
<a href="/jump?v2ray-url=https%3A%2F%2Fv2ray.example.com%2Ffree.txt%3Fformat%3Dv2ray">V2Ray URL</a>
<a href="/jump?subscriptionUrl=..%2Fcamel%2Fdaily.yaml%3Ftarget%3Dclash">Subscription camel</a>
<a href="/jump?clashUrl=%2Fclient%2Fclash.yaml%3Fformat%3Dclash">Clash camel</a>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(
            urls.contains(&"https://example.com/daily/subscription.yaml?target=clash".to_string())
        );
        assert!(urls.contains(&"https://example.com/api/subscribe?token=a&type=clash".to_string()));
        assert!(urls.contains(&"https://clash.example.com/sub.yaml?format=clash".to_string()));
        assert!(urls.contains(&"https://sub.example.com/free.txt?target=clash".to_string()));
        assert!(urls.contains(&"https://v2ray.example.com/free.txt?format=v2ray".to_string()));
        assert!(urls.contains(&"https://example.com/camel/daily.yaml?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/client/clash.yaml?format=clash".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_base64_subscription_param_values() {
        let encoded_absolute =
            STANDARD.encode("https://param.example.com/daily/clash.yaml?target=clash");
        let encoded_relative = URL_SAFE.encode("/api/subscription?token=a&format=clash");
        let text = format!(
            r#"
<a href="/jump?url={encoded_absolute}">Encoded absolute</a>
<a href="/client?sub={encoded_relative}">Encoded relative</a>
"#
        );

        let urls = discover_urls(&text, "https://example.com/free-node/index.html");

        assert!(
            urls.contains(&"https://param.example.com/daily/clash.yaml?target=clash".to_string())
        );
        assert!(
            urls.contains(&"https://example.com/api/subscription?token=a&format=clash".to_string())
        );
    }

    #[test]
    fn test_discover_urls_reads_standalone_percent_encoded_absolute_urls() {
        let text = r#"
<button data-clipboard-text="https%3A%2F%2Fcdn.example.com%2Fdaily%2Fclash.yaml%3Ftoken%3Da%2520b%26type%3Dclash">copy</button>
<script>window.sub = 'http%3A%2F%2Fmirror.example.com%2Fsub%2Flist.txt%3Fformat%3Dclash';</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://cdn.example.com/daily/clash.yaml?token=a%20b&type=clash".to_string()
        ));
        assert!(urls.contains(&"http://mirror.example.com/sub/list.txt?format=clash".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_base64_encoded_absolute_urls() {
        let encoded =
            STANDARD.encode("https://encoded.example.com/daily/clash.yaml?token=a&target=clash");
        let text = format!(r#"<script>window.encodedSub = "{encoded}";</script>"#);

        let urls = discover_urls(&text, "https://example.com/free-node/");

        assert!(urls.contains(
            &"https://encoded.example.com/daily/clash.yaml?token=a&target=clash".to_string()
        ));
    }

    #[test]
    fn test_base64_discovery_deduplicates_decoded_payloads_before_scanning() {
        let source = include_str!("free_nodes.rs");
        let body = source
            .split("fn add_base64_discovered_urls")
            .nth(1)
            .and_then(|rest| rest.split("fn has_escaped_absolute_url_hint").next())
            .expect("add_base64_discovered_urls body");

        assert!(
            body.contains("has_discoverable_url_payload_hint(&decoded)"),
            "decoded base64 discovery should skip full URL scans when the decoded text has no URL discovery hint"
        );
        assert!(
            body.contains("DecodedCandidateStorage::default()"),
            "decoded base64 discovery should lazily deduplicate repeated decoded payloads"
        );
        assert!(
            body.contains("insert_and_visit"),
            "decoded base64 discovery should visit only accepted unique decoded payloads"
        );

        let encoded = STANDARD.encode("https://encoded.example.com/daily/clash.yaml?target=clash");
        let text = format!(r#"<script>a="{encoded}";b="{encoded}";c="{encoded}";</script>"#);
        let urls = discover_urls(&text, "https://example.com/free-node/");

        assert_eq!(
            urls.iter()
                .filter(|url| url.as_str()
                    == "https://encoded.example.com/daily/clash.yaml?target=clash")
                .count(),
            1
        );
    }

    #[test]
    fn test_discover_urls_reads_base64_encoded_relative_subscription_urls() {
        let encoded = STANDARD.encode(
            r#"
{
  "clash": "/api/free?target=clash",
  "daily": "daily/free.yaml",
  "logo": "assets/logo.png"
}
"#,
        );
        let text = format!(r#"<script>window.encodedSub = "{encoded}";</script>"#);

        let urls = discover_urls(&text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free.yaml".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discovery_scanner_hints_gate_expensive_extractors() {
        let plain = "plain page without encoded subscription urls";

        assert!(!has_escaped_absolute_url_hint(plain));
        assert!(!has_json_unicode_absolute_url_hint(plain));
        assert!(!has_html_entity_absolute_url_hint(plain));
        assert!(!has_percent_encoded_absolute_url_hint(plain));
        assert!(!has_subscription_param_hint(plain));
        assert!(!has_discovery_attribute_hint(plain));
        assert!(!has_quoted_literal_hint(plain));

        assert!(has_escaped_absolute_url_hint(
            r#"https:\/\/example.com\/sub.yaml"#
        ));
        assert!(has_discoverable_url_payload_hint(
            "https://example.com/sub.yaml"
        ));
        assert!(has_discoverable_url_payload_hint(
            "//cdn.example.com/sub.yaml"
        ));
        assert!(has_json_unicode_absolute_url_hint(
            r#"https:\u002F\u002Fexample.com\u002Fsub.yaml"#
        ));
        assert!(has_discoverable_url_payload_hint(
            r#"https:\u002F\u002Fexample.com\u002Fsub.yaml"#
        ));
        assert!(has_json_unicode_absolute_url_hint(
            r#"https\u003A\u002F\u002Fexample.com\u002Fsub.yaml"#
        ));
        assert!(has_html_entity_absolute_url_hint(
            "https:&#x2F;&#x2F;example.com&#x2F;sub.yaml"
        ));
        assert!(has_percent_encoded_absolute_url_hint(
            "https%3A%2F%2Fexample.com%2Fsub.yaml"
        ));
        assert!(has_subscription_param_hint("url=/api/subscribe"));
        assert!(has_subscription_param_hint(
            r#"<a href="/jump?profileUrl=/api/profile?target=clash">"#
        ));
        assert!(!has_subscription_param_hint(
            r#"<img data-avatar-url="/assets/avatar.png" alt="free">"#
        ));
        assert!(!has_subscription_param_hint(
            r#"<form action="/login"><input name="q" value="free"><button type="submit">go</button></form>"#
        ));
        assert!(has_discovery_attribute_hint(
            r#"<button DATA-SUB="api/free">"#
        ));
        assert!(has_quoted_literal_hint(r#""/api/subscribe""#));
        assert!(!has_discoverable_url_payload_hint(
            "base64 decoded payload without any subscription url hints"
        ));
    }

    #[test]
    fn test_discovered_url_index_deduplicates_without_losing_hash_collisions() {
        let urls = insert_discovered_urls_with_forced_fingerprint_for_testing([
            "https://example.com/a.yaml",
            "https://example.com/b.yaml",
            "https://example.com/a.yaml",
        ]);

        assert_eq!(
            urls,
            vec![
                "https://example.com/a.yaml".to_string(),
                "https://example.com/b.yaml".to_string(),
            ]
        );
    }

    #[test]
    fn test_discover_urls_reads_relative_subscription_data_attributes() {
        let text = r#"
<button data-url="/daily/20260619/clash.yaml?token=a">copy</button>
<button data-sub='../sub/list.txt?format=clash'>copy</button>
<button data-clipboard-text="./feeds/free.yaml">copy</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/daily/20260619/clash.yaml?token=a".to_string()));
        assert!(urls.contains(&"https://example.com/sub/list.txt?format=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/feeds/free.yaml".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_named_subscription_data_attributes() {
        let text = r#"
<button data-subscribe-url="/api/subscribe?token=a">copy</button>
<button data-subscription-url='../daily/clash.yml'>copy</button>
<button data-sub-url="//cdn.example.com/free/clash.yaml">copy</button>
<button data-subscription="/api/v1/free?target=clash">copy</button>
<button data-config='daily/config.yml'>copy</button>
<button data-clash="./clash.txt">copy</button>
<button data-sub-url="https:\/\/escaped.example.com\/free\/clash.yaml?token=a&amp;target=clash">copy</button>
<button data-source-url="/sources/free-node">copy</button>
<button data-config="/assets/icon.PNG">asset</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/subscribe?token=a".to_string()));
        assert!(urls.contains(&"https://example.com/daily/clash.yml".to_string()));
        assert!(urls.contains(&"https://cdn.example.com/free/clash.yaml".to_string()));
        assert!(urls.contains(&"https://example.com/api/v1/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/config.yml".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/clash.txt".to_string()));
        assert!(urls.contains(
            &"https://escaped.example.com/free/clash.yaml?token=a&target=clash".to_string()
        ));
        assert!(urls.contains(&"https://example.com/sources/free-node".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/icon.PNG".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_base64_subscription_data_attributes() {
        let encoded_absolute =
            STANDARD.encode("https://attr.example.com/free/clash.yaml?target=clash");
        let encoded_relative = URL_SAFE.encode("../daily/attr.yaml?format=clash");
        let text = format!(
            r#"
<button data-sub="{encoded_absolute}">copy</button>
<button data-config="{encoded_relative}">copy</button>
"#
        );

        let urls = discover_urls(&text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://attr.example.com/free/clash.yaml?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/daily/attr.yaml?format=clash".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_extended_subscription_data_attributes() {
        let text = r#"
<button data-subscription-link=/daily/free.yaml?target=clash>copy</button>
<button data-clash-url=api/clash?token=a>copy</button>
<button data-v2ray-url=./sub/v2ray.txt>copy</button>
<button data-node-url=assets/logo.png>asset</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/daily/free.yaml?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/api/clash?token=a".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/sub/v2ray.txt".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_profile_subscription_data_attributes() {
        let text = r#"
<button data-subscribe=/api/subscribe?token=a>copy</button>
<button data-subscribe-link=profiles/free.yaml>copy</button>
<button data-profile-url=./profile/clash.txt?format=clash>copy</button>
<button data-profile-link=assets/banner.png>asset</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/subscribe?token=a".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/profiles/free.yaml".to_string()));
        assert!(urls
            .contains(&"https://example.com/free-node/profile/clash.txt?format=clash".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/banner.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_copy_and_link_subscription_data_attributes() {
        let text = r#"
<button data-copy="/api/copy/free.yaml?target=clash">copy</button>
<button data-copy-url=profiles/copy.txt?format=clash>copy</button>
<button data-link-url="https://link.example.com/free/sub.yaml?token=a">link</button>
<button data-link="/assets/banner.png">asset</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/copy/free.yaml?target=clash".to_string()));
        assert!(urls
            .contains(&"https://example.com/free-node/profiles/copy.txt?format=clash".to_string()));
        assert!(urls.contains(&"https://link.example.com/free/sub.yaml?token=a".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/banner.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_download_subscription_fields() {
        let text = r#"
<button data-download-url=api/free>download</button>
<button data-download="/daily/free.yaml?target=clash">download</button>
<button data-download-url=assets/banner.png>asset</button>
<script>
window.files = {
  downloadUrl: "api/free",
  download_url: "./daily/free",
  "download-url": "../subs/free",
  iconDownloadUrl: "assets/icon.png"
};
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/free-node/api/free".to_string()));
        assert!(urls.contains(&"https://example.com/daily/free.yaml?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free".to_string()));
        assert!(urls.contains(&"https://example.com/subs/free".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/banner.png".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/icon.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_subscription_input_value_attributes() {
        let encoded = STANDARD.encode("https://value.example.com/free/clash.yaml?target=clash");
        let text = format!(
            r#"
<input id="subscribeUrl" value="/api/subscribe?token=a&target=clash">
<input name="clash-subscription" value="../daily/free.yaml?format=clash">
<input data-role="subscription" value="{encoded}">
<input name="q" value="free">
<input name="avatar" value="/assets/logo.png">
"#
        );

        let urls = discover_urls(&text, "https://example.com/free-node/index.html");

        assert!(
            urls.contains(&"https://example.com/api/subscribe?token=a&target=clash".to_string())
        );
        assert!(urls.contains(&"https://example.com/daily/free.yaml?format=clash".to_string()));
        assert!(
            urls.contains(&"https://value.example.com/free/clash.yaml?target=clash".to_string())
        );
        assert!(!urls.contains(&"https://example.com/free-node/free".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_subscription_data_attributes_with_spaces_and_case() {
        let text = r#"
<button DATA-SUBSCRIBE-URL = "api/free">copy</button>
<img DATA-SUBSCRIBE-URL = "assets/logo.png">
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/free-node/api/free".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_mixed_case_absolute_urls() {
        let text = "daily subscription: HTTPS://cdn.example.com/Daily/Free.YAML?TARGET=CLASH";

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"HTTPS://cdn.example.com/Daily/Free.YAML?TARGET=CLASH".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_protocol_relative_absolute_urls_once() {
        let text = r#"
daily: //cdn.example.com/free/clash.yaml?target=clash
mirror: https://cdn.example.com/free/clash.yaml?target=clash
comment: // not-a-url
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://cdn.example.com/free/clash.yaml?target=clash".to_string()));
        assert_eq!(
            urls.iter()
                .filter(|url| url.as_str()
                    == "https://cdn.example.com/free/clash.yaml?target=clash")
                .count(),
            1
        );
        assert!(!urls.contains(&"https://".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_escaped_protocol_relative_absolute_urls_once() {
        let text = r#"
daily: \/\/cdn.example.com\/free\/clash.yaml?target=clash
mirror: https:\/\/cdn.example.com\/free\/clash.yaml?target=clash
other: \/\/ not-a-url
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://cdn.example.com/free/clash.yaml?target=clash".to_string()));
        assert_eq!(
            urls.iter()
                .filter(|url| url.as_str()
                    == "https://cdn.example.com/free/clash.yaml?target=clash")
                .count(),
            1
        );
        assert!(!urls.contains(&"https://".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_relative_subscription_string_literals() {
        let text = r#"
<script>
window.__SUBS__ = {
  clash: "/API/v1/client/Subscribe?token=a&TARGET=CLASH",
  yaml: "./Daily/Free.YAML",
  text: '../SUB/list.TxT?TARGET=CLASH',
  escaped: "daily\/config.yml?token=a&amp;target=clash",
  logo: "/assets/logo.PNG"
};
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(
            &"https://example.com/API/v1/client/Subscribe?token=a&TARGET=CLASH".to_string()
        ));
        assert!(urls.contains(&"https://example.com/free-node/Daily/Free.YAML".to_string()));
        assert!(urls.contains(&"https://example.com/SUB/list.TxT?TARGET=CLASH".to_string()));
        assert!(urls.contains(
            &"https://example.com/free-node/daily/config.yml?token=a&target=clash".to_string()
        ));
        assert!(!urls.contains(&"https://example.com/assets/logo.PNG".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_bare_relative_subscription_string_literals() {
        let text = r#"
<script>
window.__SUBS__ = {
  daily: "daily/free.yaml",
  directFile: "free.txt",
  subscribeApi: "api/subscribe?token=a&target=clash",
  logo: "assets/logo.png",
  word: "clash"
};
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/free-node/daily/free.yaml".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/free.txt".to_string()));
        assert!(urls.contains(
            &"https://example.com/free-node/api/subscribe?token=a&target=clash".to_string()
        ));
        assert!(!urls.contains(&"https://example.com/free-node/assets/logo.png".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/clash".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_contextual_relative_subscription_string_literals() {
        let text = r#"
<script>
window.__SUBS__ = {
  SubscribeURL: "API/Free",
  "SubscriptionURL": "Daily/Node",
  logoUrl: "Assets/Logo.PNG"
};
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/free-node/API/Free".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/Daily/Node".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/Assets/Logo.PNG".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_script_navigation_relative_subscription_literals() {
        let text = r#"
<script>
location.assign('/api/client/free?target=clash');
window.location.replace("./daily/free");
window.open('../sub/free-node');
window.open('/assets/logo.png');
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/client/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free".to_string()));
        assert!(urls.contains(&"https://example.com/sub/free-node".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_location_assignment_relative_subscription_literals() {
        let text = r#"
<script>
location = '/api/client/free?target=clash';
window.location = "./daily/free";
window.location = '/assets/logo.png';
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/client/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_script_copy_relative_subscription_literals() {
        let text = r#"
<script>
copySub('/api/client/free?target=clash');
navigator.clipboard.writeText("./daily/free");
clipboard.writeText('../sub/free-node');
copyLink('/assets/logo.png');
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/client/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free".to_string()));
        assert!(urls.contains(&"https://example.com/sub/free-node".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_common_copy_function_relative_subscription_literals() {
        let text = r#"
<script>
copyToClipboard('/api/client/free?target=clash');
copySubscription("./daily/free");
copyClash('../sub/free-node');
setClipboard('/assets/logo.png');
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/client/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free".to_string()));
        assert!(urls.contains(&"https://example.com/sub/free-node".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_html_entity_quoted_onclick_subscription_literals() {
        let text = r#"
<button onclick="copySub(&quot;/api/client/free?target=clash&quot;)">Copy Clash</button>
<button onclick='copySubscription(&#39;./daily/free.yaml&#39;)'>Copy Daily</button>
<button onclick="copyConfig(&QUOT;../upper/free.yaml?target=clash&QUOT;)">Copy Upper</button>
<button onclick="copyLink(&quot;/assets/logo.png&quot;)">Logo</button>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/client/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free.yaml".to_string()));
        assert!(urls.contains(&"https://example.com/upper/free.yaml?target=clash".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_script_concatenated_relative_subscription_literals() {
        let text = r#"
<script>
copySub('/api/client/' + 'free?target=clash');
navigator.clipboard.writeText("./daily/" + "free");
copyLink('/assets/' + 'logo.png');
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/client/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free".to_string()));
        assert!(!urls.contains(&"https://example.com/api/client/".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/free?target=clash".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_static_template_relative_subscription_literals() {
        let text = r#"
<script>
copySub(`/api/client/free?target=clash`);
window.open(`./daily/free`);
copySub(`/api/${dailyPath}`);
copyLink(`/assets/logo.png`);
</script>
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(urls.contains(&"https://example.com/api/client/free?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/daily/free".to_string()));
        assert!(!urls.contains(&"https://example.com/api/".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_markdown_relative_subscription_links() {
        let text = r#"
# Free nodes

- [Clash subscription](daily/free.yaml?target=clash)
- [V2Ray nodes](<API/Free>)
- ![logo](assets/logo.png)
- [Docs](README.md)
"#;

        let urls = discover_urls(text, "https://example.com/free-node/README.md");

        assert!(urls
            .contains(&"https://example.com/free-node/daily/free.yaml?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/API/Free".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/logo.png".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/README.md".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_markdown_reference_subscription_links() {
        let text = r#"
# Free nodes

[Clash subscription]: daily/free.yaml?target=clash "daily"
[V2Ray nodes]: <API/Free>
[Docs]: README.md
[Logo]: assets/logo.png
"#;

        let urls = discover_urls(text, "https://example.com/free-node/README.md");

        assert!(urls
            .contains(&"https://example.com/free-node/daily/free.yaml?target=clash".to_string()));
        assert!(urls.contains(&"https://example.com/free-node/API/Free".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/README.md".to_string()));
        assert!(!urls.contains(&"https://example.com/free-node/assets/logo.png".to_string()));
    }

    #[test]
    fn test_add_config_or_page_keeps_proxy_list_data_file_links_as_configs() {
        let source = Arc::new(CandidateSource::from_source(&SourceInput {
            id: "proxy-data-page".into(),
            label: "Proxy Data Page".into(),
            seed: "https://example.com/free-node/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        }));
        let mut configs = HashMap::<String, Arc<CandidateSource>>::new();
        let mut page_queue = VecDeque::<ConfigCandidate>::new();
        let mut visited_pages = HashSet::<String>::new();
        let mut visited_page_fetch_keys = HashSet::<String>::new();

        for url in [
            "https://example.com/daily/proxylist.csv",
            "https://example.com/daily/proxylist.xml",
            "https://example.com/daily/proxylist.phps",
            "https://example.com/daily/http.csv",
            "https://example.com/daily/https.csv",
            "https://example.com/daily/socks5.csv",
            "https://example.com/daily/socks4.csv",
            "https://example.com/daily/socks4.txt",
        ] {
            add_config_or_page(
                &mut configs,
                &mut page_queue,
                &mut visited_pages,
                &mut visited_page_fetch_keys,
                url,
                &source,
            );
        }

        assert_eq!(configs.len(), 6);
        assert!(configs.contains_key("https://example.com/daily/proxylist.csv"));
        assert!(configs.contains_key("https://example.com/daily/proxylist.xml"));
        assert!(configs.contains_key("https://example.com/daily/proxylist.phps"));
        assert!(configs.contains_key("https://example.com/daily/http.csv"));
        assert!(configs.contains_key("https://example.com/daily/https.csv"));
        assert!(configs.contains_key("https://example.com/daily/socks5.csv"));
        assert!(!configs.contains_key("https://example.com/daily/socks4.csv"));
        assert!(!configs.contains_key("https://example.com/daily/socks4.txt"));
        assert!(page_queue.is_empty());
    }

    #[test]
    fn test_discover_urls_reads_meta_refresh_subscription_urls() {
        let text = r#"
<meta http-equiv="refresh" content="0; url=/api/subscribe?token=a&target=clash">
<meta http-equiv='refresh' content='3;URL=../daily/free.yaml?format=clash'>
<meta http-equiv="refresh" content="0; url = ./profiles/free.txt?format=clash">
<meta http-equiv="refresh" content="0; url=./profiles/entity.txt?token=a&amp;format=clash">
<meta http-equiv="refresh" content="0; url=https://meta.example.com/sub.yaml?token=a&amp;format=clash">
<meta http-equiv="refresh" content="0; url='https://quoted.example.com/free.yaml?target=clash'">
<meta http-equiv="refresh" content="0; url='./quoted/free.yaml?target=clash'">
<meta http-equiv="refresh" content="0; url=/assets/logo.png">
"#;

        let urls = discover_urls(text, "https://example.com/free-node/index.html");

        assert!(
            urls.contains(&"https://example.com/api/subscribe?token=a&target=clash".to_string())
        );
        assert!(urls.contains(&"https://example.com/daily/free.yaml?format=clash".to_string()));
        assert!(urls
            .contains(&"https://example.com/free-node/profiles/free.txt?format=clash".to_string()));
        assert!(urls.contains(
            &"https://example.com/free-node/profiles/entity.txt?token=a&format=clash".to_string()
        ));
        assert!(
            urls.contains(&"https://meta.example.com/sub.yaml?token=a&format=clash".to_string())
        );
        assert!(urls.contains(&"https://quoted.example.com/free.yaml?target=clash".to_string()));
        assert!(urls
            .contains(&"https://example.com/free-node/quoted/free.yaml?target=clash".to_string()));
        assert!(!urls.contains(&"https://example.com/assets/logo.png".to_string()));
    }

    #[test]
    fn test_discover_urls_reads_yaml_unquoted_provider_urls() {
        let text = r#"
proxy-providers:
  daily:
    type: http
    url: ./providers/daily.yaml?target=clash
  backup:
    type: http
    url: ../backup/list.txt?format=clash # fallback list
  asset:
    type: http
    url: assets/logo.png
  quoted:
    type: http
    "url": 'API/Free'
  remote:
    type: http
    url: https://cdn.example.com/free/clash.yaml?token=a#frag
"#;

        let urls = discover_urls(text, "https://example.com/configs/clash.yaml");

        assert!(urls.contains(
            &"https://example.com/configs/providers/daily.yaml?target=clash".to_string()
        ));
        assert!(urls.contains(&"https://example.com/backup/list.txt?format=clash".to_string()));
        assert!(urls.contains(&"https://example.com/configs/API/Free".to_string()));
        assert!(urls.contains(&"https://cdn.example.com/free/clash.yaml?token=a#frag".to_string()));
        assert!(!urls.contains(&"https://example.com/configs/assets/logo.png".to_string()));
    }

    #[test]
    fn test_github_api_url_capacity_hint_counts_top_level_entries() {
        let contents = serde_json::json!([
            {"download_url": "https://raw.example.com/a.yaml"},
            {"download_url": "https://raw.example.com/b.yaml"},
            {"download_url": "https://raw.example.com/c.yaml"}
        ]);
        assert_eq!(github_api_url_capacity_hint(&contents), 3);
        assert_eq!(
            github_api_url_capacity_hint(
                &serde_json::json!({"raw_url": "https://raw.example.com/d.yaml"})
            ),
            1
        );

        let tree = serde_json::json!({
            "tree": [
                {"path": "a.yaml", "type": "blob"},
                {"path": "b.yml", "type": "blob"},
                {"path": "docs", "type": "tree"}
            ]
        });
        assert_eq!(github_api_url_capacity_hint(&tree), 3);
    }

    #[test]
    fn test_discover_github_api_urls_reads_raw_url_fields() {
        let text = r#"
[
  {
    "raw_url": "https://raw.githubusercontent.com/owner/repo/main/configs/daily.yaml"
  }
]
"#;

        let urls = discover_github_api_urls(
            text,
            "https://api.github.com/repos/owner/repo/contents?ref=main",
        )
        .expect("github api urls");

        assert!(urls.contains(
            &"https://raw.githubusercontent.com/owner/repo/main/configs/daily.yaml".to_string()
        ));
    }

    #[test]
    fn test_page_discovery_reuses_agent_cache_per_worker() {
        let source = SourceInput {
            id: "page".into(),
            label: "Page".into(),
            seed: "https://page.example.com/".into(),
            rank: 0,
            update_interval_hours: 24,
            page_discovery: true,
            github_discovery: false,
            raw_candidates: vec![],
            candidate_urls: vec![],
        };
        let input = FreeNodesInput {
            catalog: CatalogInput {
                history_timeout_hours: 72,
                sources: vec![source.clone()],
            },
            enabled_source_ids: vec!["page".into()],
            source_ids: None,
            existing_config_text: None,
            preference: PreferenceInput {
                fetch_concurrency: 1,
                auto_prefer: false,
            },
            fetch_timeout_seconds_by_source: HashMap::new(),
            default_fetch_timeout_seconds: 10,
            proxy_url: None,
            user_agent: "test".into(),
            today_label: "2026-06-19".into(),
            today_token: 20260619,
            now_day_number: 0,
            now_iso: "2026-06-19T00:00:00".into(),
        };
        let pages = VecDeque::from([
            ConfigCandidate::from_source_ref("https://page.example.com/a/".into(), &source),
            ConfigCandidate::from_source_ref("https://page.example.com/b/".into(), &source),
        ]);
        let cache_lengths = Arc::new(Mutex::new(Vec::new()));
        let seen = Arc::clone(&cache_lengths);

        let configs = discover_pages_with_fetcher(
            &input,
            HashMap::new(),
            pages,
            HashSet::new(),
            2,
            &|_, _, url, agent_cache| {
                seen.lock().unwrap().push(agent_cache.len());
                agent_cache.get(10, None).unwrap();
                Ok(if url.ends_with("/a/") {
                    r#"<a href="a.yaml">a</a>"#.to_string()
                } else {
                    r#"<a href="https://page.example.com/b.yaml">b</a>"#.to_string()
                })
            },
        );

        assert!(configs.contains_key("https://page.example.com/a/a.yaml"));
        assert!(configs.contains_key("https://page.example.com/b.yaml"));
        assert_eq!(cache_lengths.lock().unwrap().as_slice(), &[0, 1]);
    }
}
