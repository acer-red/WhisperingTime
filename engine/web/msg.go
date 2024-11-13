package web

type MSG struct {
	Err  MsgErr      `json:"err"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data"`
}

type MsgErr int

const (
	msOK             MsgErr = iota // 0
	msInternalServer               // 1
	msNoData                       // 2
)

func (msg MSG) setData(data interface{}) MSG {
	msg.Data = data
	return msg
}
func msgOK(msg ...string) MSG {
	m := MSG{Err: msOK}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = "ok"
	}
	return m
}
func msgInternalServer(msg ...string) MSG {
	m := MSG{Err: 1}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = "内部系统错误"
	}
	return m
}
