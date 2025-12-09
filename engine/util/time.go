package util

import (
	"fmt"
	"strconv"
	"time"
)

func YYYY() int {
	return time.Now().Year()
}
func MM() int {
	return int(time.Now().Month())
}
func YYYYToInt(s string) int {
	if s == "" {
		return 0
	}
	i, err := strconv.Atoi(s)
	if err != nil || i <= 0 {
		return YYYY()
	}
	return i
}
func MMToInt(s string) int {
	if s == "" {
		return 0
	}
	i, err := strconv.Atoi(s)
	if err != nil || i <= 0 {
		return MM()
	}
	return i
}
func StringtoTime(s string) time.Time {
	if i, err := strconv.Atoi(s); err == nil {
		return time.Unix(int64(i), 0)
	}
	t, err := time.Parse("2006-01-02 15:04:05", s)
	if err != nil {
		fmt.Println(err)
		return time.Now()
	}
	return t
}
func YYYYMMDDhhmmss() string {
	t := time.Now()
	y := t.Year()
	m := int(t.Month())
	d := int(t.Day())
	hour := t.Hour()
	min := t.Minute()
	sec := t.Second()
	return fmt.Sprintf("%04d%02d%02d%02d%02d%02d", y, m, d, hour, min, sec)
}
