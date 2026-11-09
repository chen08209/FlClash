package timezone

// #include <stdlib.h>
// #include <sys/system_properties.h>
// #include <time.h>
import "C"

import (
	"time"
	"unsafe"
)

func init() {
	key := C.CString("persist.sys.timezone")
	defer C.free(unsafe.Pointer(key))
	var value [C.PROP_VALUE_MAX]C.char
	if C.__system_property_get(key, &value[0]) <= 0 {
		return
	}
	name := C.GoString(&value[0])
	location, err := time.LoadLocation(name)
	if err != nil {
		location = time.FixedZone(name, gmtOffset())
	}
	time.Local = location
}

// bionic finds its tzdata where Go's LoadLocation may not look.
func gmtOffset() int {
	now := C.time(nil)
	var local C.struct_tm
	if C.localtime_r(&now, &local) == nil {
		return 0
	}
	return int(local.tm_gmtoff)
}
