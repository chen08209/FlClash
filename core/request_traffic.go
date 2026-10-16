package core

import (
	"sync"
	"time"

	"github.com/metacubex/mihomo/tunnel/statistic"
)

// mihomo announces a connection only as it opens, and has no hook for its
// close; the request list learns the traffic that follows from these reports.
const requestTrafficInterval = time.Second

// A full bulk queue drops a report; a closed request holds its connection only this many retries.
const requestTrafficCloseRetries = 5

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
	fresh         bool
	closedReports int
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

func (w *requestTrafficWatch) collect(
	isOpen func(id string) bool,
	queue func([]RequestTraffic) (queued bool),
) (watching bool) {
	w.mu.Lock()
	defer w.mu.Unlock()
	var changed []RequestTraffic
	for id, request := range w.requests {
		if request.closedReports > 0 || !request.fresh && !isOpen(id) {
			request.closedReports++
		}
		request.fresh = false
		info := request.tracker.Info()
		upload, download := info.UploadTotal.Load(), info.DownloadTotal.Load()
		if upload != request.upload || download != request.download {
			changed = append(changed, RequestTraffic{Id: id, Upload: upload, Download: download})
		}
	}
	queued := len(changed) == 0 || queue(changed)
	if queued {
		for _, traffic := range changed {
			request := w.requests[traffic.Id]
			request.upload, request.download = traffic.Upload, traffic.Download
		}
	}
	for id, request := range w.requests {
		if request.closedReports > 0 && (queued || request.closedReports > requestTrafficCloseRetries) {
			delete(w.requests, id)
		}
	}
	w.running = len(w.requests) > 0
	return w.running
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
		watching := currentRequestTraffic.collect(
			func(id string) bool {
				return statistic.DefaultManager.Get(id) != nil
			},
			func(changed []RequestTraffic) bool {
				return sendMessage(RequestTrafficMessage, changed)
			},
		)
		if !watching {
			return
		}
	}
}
