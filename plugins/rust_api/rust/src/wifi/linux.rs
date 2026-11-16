use crate::api::wifi::WifiSsidPermission;
use serde::de::DeserializeOwned;
use serde::Serialize;
use std::collections::HashMap;
use std::process::{Command, Stdio};
use std::time::Duration;
use tokio::time::timeout;
use zbus::zvariant::{DynamicType, OwnedObjectPath, OwnedValue, Type};
use zbus::Connection;

const CALL_TIMEOUT: Duration = Duration::from_secs(1);
const NM: &str = "org.freedesktop.NetworkManager";
const NM_DEVICE: &str = "org.freedesktop.NetworkManager.Device";
const NM_WIRELESS: &str = "org.freedesktop.NetworkManager.Device.Wireless";
const NM_ACCESS_POINT: &str = "org.freedesktop.NetworkManager.AccessPoint";
const NM_DEVICE_TYPE_WIFI: u32 = 2;
const NM_DEVICE_STATE_ACTIVATED: u32 = 100;
const IWD: &str = "net.connman.iwd";
const CONNMAN: &str = "net.connman";

type ManagedObjects = HashMap<OwnedObjectPath, HashMap<String, HashMap<String, OwnedValue>>>;
type Services = Vec<(OwnedObjectPath, HashMap<String, OwnedValue>)>;

async fn call<B, R>(
    connection: &Connection,
    destination: &str,
    path: &str,
    interface: &str,
    method: &str,
    body: &B,
) -> Option<R>
where
    B: Serialize + DynamicType,
    R: DeserializeOwned + Type,
{
    let reply = timeout(
        CALL_TIMEOUT,
        connection.call_method(Some(destination), path, Some(interface), method, body),
    )
    .await
    .ok()?
    .ok()?;
    reply.body().deserialize().ok()
}

async fn property<T: TryFrom<OwnedValue>>(
    connection: &Connection,
    destination: &str,
    path: &str,
    interface: &str,
    name: &str,
) -> Option<T> {
    let value: OwnedValue = call(
        connection,
        destination,
        path,
        "org.freedesktop.DBus.Properties",
        "Get",
        &(interface, name),
    )
    .await?;
    T::try_from(value).ok()
}

async fn network_manager(connection: &Connection) -> Option<String> {
    let devices: Vec<OwnedObjectPath> = call(
        connection,
        NM,
        "/org/freedesktop/NetworkManager",
        NM,
        "GetDevices",
        &(),
    )
    .await?;
    for device in devices {
        let device = device.as_str();
        if property::<u32>(connection, NM, device, NM_DEVICE, "DeviceType").await
            != Some(NM_DEVICE_TYPE_WIFI)
            || property::<u32>(connection, NM, device, NM_DEVICE, "State").await
                != Some(NM_DEVICE_STATE_ACTIVATED)
        {
            continue;
        }
        let Some(access_point) =
            property::<OwnedObjectPath>(connection, NM, device, NM_WIRELESS, "ActiveAccessPoint")
                .await
                .filter(|path| path.as_str() != "/")
        else {
            continue;
        };
        let ssid = property::<Vec<u8>>(
            connection,
            NM,
            access_point.as_str(),
            NM_ACCESS_POINT,
            "Ssid",
        )
        .await
        .filter(|ssid| !ssid.is_empty());
        if let Some(ssid) = ssid {
            return Some(String::from_utf8_lossy(&ssid).into_owned());
        }
    }
    None
}

async fn iwd(connection: &Connection) -> Option<String> {
    let objects: ManagedObjects = call(
        connection,
        IWD,
        "/",
        "org.freedesktop.DBus.ObjectManager",
        "GetManagedObjects",
        &(),
    )
    .await?;
    for interfaces in objects.into_values() {
        let Some(network) = interfaces
            .get("net.connman.iwd.Station")
            .and_then(|station| station.get("ConnectedNetwork"))
            .and_then(|path| OwnedObjectPath::try_from(path.try_clone().ok()?).ok())
            .filter(|path| path.as_str() != "/")
        else {
            continue;
        };
        if let Some(name) = property::<String>(
            connection,
            IWD,
            network.as_str(),
            "net.connman.iwd.Network",
            "Name",
        )
        .await
        {
            return Some(name);
        }
    }
    None
}

async fn connman(connection: &Connection) -> Option<String> {
    let services: Services = call(
        connection,
        CONNMAN,
        "/",
        "net.connman.Manager",
        "GetServices",
        &(),
    )
    .await?;
    services.into_iter().find_map(|(_, properties)| {
        let text = |name: &str| {
            properties
                .get(name)
                .and_then(|value| <&str>::try_from(value).ok())
        };
        (text("Type") == Some("wifi") && matches!(text("State"), Some("online" | "ready")))
            .then(|| text("Name"))
            .flatten()
            .filter(|name| !name.is_empty())
            .map(str::to_owned)
    })
}

fn nmcli() -> Option<String> {
    let output = Command::new("nmcli")
        .args(["--terse", "--fields", "active,ssid", "device", "wifi"])
        .env("LC_ALL", "C")
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()
        .ok()
        .filter(|output| output.status.success())?;
    super::nmcli::active_ssid(&String::from_utf8_lossy(&output.stdout))
}

pub async fn ssid() -> Result<Option<String>, String> {
    if let Ok(Ok(connection)) = timeout(CALL_TIMEOUT, Connection::system()).await {
        for ssid in [
            network_manager(&connection).await,
            iwd(&connection).await,
            connman(&connection).await,
        ] {
            if let Some(ssid) = super::non_empty(ssid) {
                return Ok(Some(ssid));
            }
        }
    }
    let ssid = tokio::task::spawn_blocking(nmcli)
        .await
        .map_err(|error| error.to_string())?;
    Ok(super::non_empty(ssid))
}

pub async fn check_permission() -> WifiSsidPermission {
    WifiSsidPermission::Granted
}

pub async fn request_permission() -> WifiSsidPermission {
    WifiSsidPermission::Granted
}
