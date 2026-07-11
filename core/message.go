package main

import "time"

const (
	messageBatchInterval = 16 * time.Millisecond
	messageBatchSize     = 32
	messageQueueSize     = 256
)

var (
	priorityMessageQueue = make(chan Message, messageQueueSize)
	bulkMessageQueue     = make(chan Message, messageQueueSize)
)

func init() {
	go runMessageBatcher(priorityMessageQueue, bulkMessageQueue, sendMessageBatch)
}

func sendMessage(message Message) {
	queue := priorityMessageQueue
	if message.Type == LogMessage || message.Type == RequestMessage {
		queue = bulkMessageQueue
	}
	enqueueLatest(queue, message)
}

func enqueueLatest(queue chan Message, message Message) {
	select {
	case queue <- message:
		return
	default:
	}

	// Event delivery must never block the core. Each priority class evicts only
	// its own oldest event, so log or request floods cannot displace state.
	select {
	case <-queue:
	default:
	}
	select {
	case queue <- message:
	default:
	}
}

func runMessageBatcher(
	priorityMessages <-chan Message,
	bulkMessages <-chan Message,
	send func([]Message),
) {
	ticker := time.NewTicker(messageBatchInterval)
	defer ticker.Stop()

	batch := make([]Message, 0, messageBatchSize)
	flush := func() {
		if len(batch) == 0 {
			return
		}
		current := append([]Message(nil), batch...)
		batch = batch[:0]
		send(current)
	}
	appendMessage := func(message Message) {
		batch = append(batch, message)
		if len(batch) >= messageBatchSize {
			flush()
		}
	}

	for priorityMessages != nil || bulkMessages != nil {
		// Prefer state-bearing events whenever both queues have work.
		select {
		case message, ok := <-priorityMessages:
			if !ok {
				priorityMessages = nil
			} else {
				appendMessage(message)
			}
			continue
		default:
		}

		select {
		case message, ok := <-priorityMessages:
			if !ok {
				priorityMessages = nil
			} else {
				appendMessage(message)
			}
		case message, ok := <-bulkMessages:
			if !ok {
				bulkMessages = nil
			} else {
				appendMessage(message)
			}
		case <-ticker.C:
			flush()
		}
	}
	flush()
}
