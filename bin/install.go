package hades

import (
	"fmt"
	"runtime"
)

/**
 * Download latest release from github
 * Copy & regiter units
 * Start service
 */

func main() {

	//run only on linux
	if runtime.GOOS != "linux" {
		fmt.Println("OS Detection failed")
		return
	}

}
