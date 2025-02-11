//go:build !cgo

package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"net"
	"strconv"
)

var conn net.Conn

func sendMessage(message Message) {
	res, err := message.Json()
	if err != nil {
		return
	}
	send(Action{
		Method: messageMethod,
	}.getResult(res))
}

func send(data []byte) {
	if conn == nil {
		return
	}
	_, _ = conn.Write(append(data, []byte("\n")...))
}

func startServer(arg string) {

	_, err := strconv.Atoi(arg)

	if err != nil {
		conn, err = net.Dial("unix", arg)
	} else {
		conn, err = net.Dial("tcp", fmt.Sprintf("127.0.0.1:%s", arg))
	}
	if err != nil {
		panic(err.Error())
	}

	defer func(conn net.Conn) {
		_ = conn.Close()
	}(conn)

	reader := bufio.NewReader(conn)

	for {
		data, err := reader.ReadString('\n')
		if err != nil {
			return
		}
		var action = &Action{}

		err = json.Unmarshal([]byte(data), action)

		if err != nil {
			return
		}

		go handleAction(action, func(data interface{}) {
			send(action.getResult(data))
		})
	}
}

func nextHandle(action *Action, result func(data interface{})) bool {
	return false
}
