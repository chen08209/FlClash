// Package timezone sets time.Local on Android, where Go reads no zone of its
// own and keeps UTC. Writing time.Local races every goroutine reading the
// clock, so it is written once, in an init that runs before any package
// outside the standard library that imports time. That holds while this
// package imports only what time does, plus runtime/cgo: it is then ready as
// soon as time is, and the import path order puts it first. A zone changed
// later applies from the next launch, as Go elsewhere reads the zone once too.
package timezone
