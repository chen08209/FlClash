package core

import (
	"sync"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

// mihomo announces a connection only as it opens, and has no hook for its
// close; the request list learns the traffic that follows from these reports.
const requestTrafficInterval = time.Second

type RequestTraffic struct {
	Id       string `json:"id"`
	Upload   int64  `json:"upload"`
	Download int64  `json:"download"`
}

type watchedRequest struct {
	tracker  statistic.Tracker
	upload   int64
	download int64
	// The tracker is announced before the manager stores it, so a request
	// missing from the manager on its first report may still be opening.
	fresh bool
}

type requestTrafficWatch struct {
	mu       sync.Mutex
	requests map[string]*watchedRequest
	running  bool
}

var currentRequestTraffic = requestTrafficWatch{
	requests: map[string]*watchedRequest{},
}

func (w *requestTrafficWatch) add(tracker statistic.Tracker) (start bool) {
	info := tracker.Info()
	w.mu.Lock()
	defer w.mu.Unlock()
	w.requests[tracker.ID()] = &watchedRequest{
		tracker:  tracker,
		upload:   info.UploadTotal.Load(),
		download: info.DownloadTotal.Load(),
		fresh:    true,
	}
	start = !w.running
	w.running = true
	return start
}

func (w *requestTrafficWatch) collect(isOpen func(id string) bool) (changed []RequestTraffic, watching bool) {
	w.mu.Lock()
	defer w.mu.Unlock()
	for id, request := range w.requests {
		closed := !request.fresh && !isOpen(id)
		request.fresh = false
		info := request.tracker.Info()
		upload, download := info.UploadTotal.Load(), info.DownloadTotal.Load()
		if upload != request.upload || download != request.download {
			request.upload, request.download = upload, download
			changed = append(changed, RequestTraffic{Id: id, Upload: upload, Download: download})
		}
		if closed {
			delete(w.requests, id)
		}
	}
	w.running = len(w.requests) > 0
	return changed, w.running
}

func (w *requestTrafficWatch) clear() {
	w.mu.Lock()
	defer w.mu.Unlock()
	clear(w.requests)
	w.running = false
}

func watchRequestTraffic(tracker statistic.Tracker) {
	if currentRequestTraffic.add(tracker) {
		go runRequestTrafficWatch()
	}
}

func runRequestTrafficWatch() {
	ticker := time.NewTicker(requestTrafficInterval)
	defer ticker.Stop()
	for range ticker.C {
		if !hasEventListener() {
			currentRequestTraffic.clear()
			return
		}
		changed, watching := currentRequestTraffic.collect(func(id string) bool {
			return statistic.DefaultManager.Get(id) != nil
		})
		if len(changed) > 0 {
			sendMessage(RequestTrafficMessage, changed)
		}
		if !watching {
			return
		}
	}
}
