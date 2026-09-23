//go:build linux

package platform

import (
	"bufio"
	"bytes"
	"encoding/binary"
	"encoding/hex"
	"net"
	"os"
	"strconv"
	"strings"
	"unsafe"
)

var netIndexOfLocal = -1
var netIndexOfUid = -1

var nativeEndian binary.ByteOrder

func QuerySocketUidFromProcFs(source, _ net.Addr) int {
	if netIndexOfLocal < 0 || netIndexOfUid < 0 {
		return -1
	}

	network := source.Network()

	if strings.HasSuffix(network, "4") || strings.HasSuffix(network, "6") {
		network = network[:len(network)-1]
	}

	path := "/proc/net/" + network

	var sIP net.IP
	var sPort int

	switch s := source.(type) {
	case *net.TCPAddr:
		sIP = s.IP
		sPort = s.Port
	case *net.UDPAddr:
		sIP = s.IP
		sPort = s.Port
	default:
		return -1
	}

	sIP = sIP.To16()
	if sIP == nil {
		return -1
	}

	uid := doQuery(path+"6", sIP, sPort)
	if uid == -1 {
		sIP = sIP.To4()
		if sIP == nil {
			return -1
		}
		uid = doQuery(path, sIP, sPort)
	}

	return uid
}

func localAddressColumn(sIP net.IP, sPort int) []byte {
	ip := nativeEndianIP(sIP)
	column := make([]byte, 0, hex.EncodedLen(len(ip))+1+4)

	encoded := make([]byte, hex.EncodedLen(len(ip)))
	hex.Encode(encoded, ip)
	column = append(column, encoded...)

	column = append(column, ':')

	var port [2]byte
	binary.BigEndian.PutUint16(port[:], uint16(sPort))
	var encodedPort [4]byte
	hex.Encode(encodedPort[:], port[:])
	return append(column, encodedPort[:]...)
}

func column(row []byte, index int) []byte {
	for i := 0; ; i++ {
		row = bytes.TrimLeft(row, " \t")
		if len(row) == 0 {
			return nil
		}
		end := bytes.IndexAny(row, " \t")
		if end < 0 {
			end = len(row)
		}
		if i == index {
			return row[:end]
		}
		row = row[end:]
	}
}

func doQuery(path string, sIP net.IP, sPort int) int {
	file, err := os.Open(path)
	if err != nil {
		return -1
	}

	defer func(file *os.File) {
		_ = file.Close()
	}(file)

	local := localAddressColumn(sIP, sPort)

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		row := scanner.Bytes()

		if !bytes.EqualFold(local, column(row, netIndexOfLocal)) {
			continue
		}

		uidColumn := column(row, netIndexOfUid)
		if uidColumn == nil {
			return -1
		}

		uid, err := strconv.Atoi(string(uidColumn))
		if err != nil {
			return -1
		}

		return uid
	}

	return -1
}

func nativeEndianIP(ip net.IP) []byte {
	result := make([]byte, len(ip))

	for i := 0; i < len(ip); i += 4 {
		value := binary.BigEndian.Uint32(ip[i:])

		nativeEndian.PutUint32(result[i:], value)
	}

	return result
}

func init() {
	file, err := os.Open("/proc/net/tcp")
	if err != nil {
		return
	}

	defer func(file *os.File) {
		_ = file.Close()
	}(file)

	reader := bufio.NewReader(file)

	header, _, err := reader.ReadLine()
	if err != nil {
		return
	}

	columns := strings.Fields(string(header))

	var txQueue, rxQueue, tr, tmWhen bool

	for idx, col := range columns {
		offset := 0

		if txQueue && rxQueue {
			offset--
		}

		if tr && tmWhen {
			offset--
		}

		switch col {
		case "tx_queue":
			txQueue = true
		case "rx_queue":
			rxQueue = true
		case "tr":
			tr = true
		case "tm->when":
			tmWhen = true
		case "local_address":
			netIndexOfLocal = idx + offset
		case "uid":
			netIndexOfUid = idx + offset
		}
	}
}

func init() {
	var x uint32 = 0x01020304
	if *(*byte)(unsafe.Pointer(&x)) == 0x01 {
		nativeEndian = binary.BigEndian
	} else {
		nativeEndian = binary.LittleEndian
	}
}
