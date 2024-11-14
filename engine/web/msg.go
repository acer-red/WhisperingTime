package web

type MSG struct {
	Err  MsgErr      `json:"err"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data"`
}

type MsgErr int

const (
	mseqOK             MsgErr = iota // 0
	mseqInternalServer               // 1
	mseqNoParam                      // 2
	mseqBadRequest
)
const mstrOK string = "ok"
const mstrInternalServer string = "内部系统错误"
const mstrNoParam string = "缺少参数"
const mstrNoUID string = "缺少uid参数"
const mstrNoDocID string = "缺少docID参数"
const mstrNoThemeID string = "缺少themeID参数"
const mstrBadRequest string = "错误参数"

func (msg MSG) setData(data interface{}) MSG {
	msg.Data = data
	return msg
}
func (msg MSG) setMSG(message string) MSG {
	msg.Msg = message
	return msg
}
func msgOK(msg ...string) MSG {
	m := MSG{Err: mseqOK}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrOK
	}
	return m
}
func msgInternalServer(msg ...string) MSG {
	m := MSG{Err: mseqInternalServer}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrInternalServer
	}
	return m
}
func msgNoParam(msg ...string) MSG {
	m := MSG{Err: mseqNoParam}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrNoParam
	}
	return m
}
func msgBadRequest(msg ...string) MSG {
	m := MSG{Err: mseqBadRequest}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrBadRequest
	}
	return m
}
