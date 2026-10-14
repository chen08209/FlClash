package core

import (
	"fmt"
	"strings"

	"github.com/metacubex/mihomo/component/geodata"
	"github.com/metacubex/mihomo/component/updater"
	"github.com/metacubex/mihomo/log"
)

type geoResource struct {
	update func() error
	url    func() string
	setUrl func(string)
}

var geoResources = map[string]geoResource{
	"MMDB":    {update: updater.UpdateMMDB, url: geodata.MmdbUrl, setUrl: geodata.SetMmdbUrl},
	"ASN":     {update: updater.UpdateASN, url: geodata.ASNUrl, setUrl: geodata.SetASNUrl},
	"GEOIP":   {update: updater.UpdateGeoIp, url: geodata.GeoIpUrl, setUrl: geodata.SetGeoIpUrl},
	"GEOSITE": {update: updater.UpdateGeoSite, url: geodata.GeoSiteUrl, setUrl: geodata.SetGeoSiteUrl},
}

// mihomo's updaters read these links without a lock, so an unchanged one is never rewritten.
func setGeoResourceUrl(geoType string, link string) {
	resource, exist := geoResources[strings.ToUpper(geoType)]
	if !exist {
		log.Warnln("geox-url: unknown geo resource %q", geoType)
		return
	}
	if link != "" && link != resource.url() {
		resource.setUrl(link)
	}
}

func claimGeoUpdate(geoType string) bool {
	return claimUpdate(geoUpdateScope + geoType)
}

func releaseGeoUpdate(geoType string) {
	releaseUpdate(geoUpdateScope + geoType)
}

func handleUpdateGeoData(geoType string) error {
	resource, exist := geoResources[geoType]
	if !exist {
		logError("updateGeoData: unknown geo resource %q", geoType)
		return fmt.Errorf("unknown geo resource: %s", geoType)
	}
	if !claimGeoUpdate(geoType) {
		return fmt.Errorf("geo update already in progress: %s", geoType)
	}
	safeGo("updateGeoData("+geoType+")", func() {
		defer releaseGeoUpdate(geoType)
		if err := resource.update(); err != nil {
			logError("updateGeoData(%s) error: %v", geoType, err)
		}
	})
	return nil
}

func onGeoUpdate(geoType string, updating bool, skipped bool, updateErr error) {
	if updating {
		claimUpdateAs(geoUpdateScope+geoType, true)
	} else {
		releaseHookUpdate(geoUpdateScope + geoType)
		scheduleReclaimOwnership()
		if !skipped && updateErr == nil {
			bumpRouteEpoch()
		}
	}
	status := GeoUpdateStatus{Type: geoType, Updating: updating, Skipped: skipped}
	if updateErr != nil {
		status.Error = updateErr.Error()
	}
	sendMessage(GeoUpdateMessage, status)
}

var (
	registerGeoUpdater = updater.RegisterGeoUpdaterWithCancel
	stopGeoUpdater     = updater.StopGeoUpdater
)

func syncGeoUpdater(autoUpdate *bool, interval *int) {
	changed := false
	if autoUpdate != nil && *autoUpdate != updater.GeoAutoUpdate() {
		updater.SetGeoAutoUpdate(*autoUpdate)
		changed = true
	}
	if interval != nil && *interval != updater.GeoUpdateInterval() {
		updater.SetGeoUpdateInterval(*interval)
		changed = true
	}
	if changed {
		reconcileGeoUpdater()
	}
}

func reconcileGeoUpdater() {
	if updater.GeoAutoUpdate() {
		registerGeoUpdater()
		return
	}
	stopGeoUpdater()
}
