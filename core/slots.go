package core

import (
	"context"
	"time"
)

type slots chan struct{}

func (s slots) acquire(ctx context.Context) bool {
	if ctx.Err() != nil {
		return false
	}
	select {
	case s <- struct{}{}:
		return true
	case <-ctx.Done():
		return false
	}
}

// The wait has a deadline of its own, so the work after it keeps its whole budget.
func (s slots) acquireWithin(parent context.Context, timeout time.Duration) bool {
	ctx, cancel := context.WithTimeout(parent, timeout)
	defer cancel()
	return s.acquire(ctx)
}

func (s slots) release() {
	<-s
}

func timeoutFromMillis(millis int64, fallback time.Duration) time.Duration {
	if millis <= 0 {
		return fallback
	}
	return time.Duration(millis) * time.Millisecond
}
