package web

import (
	"bytes"
	"net/http"
	"strings"

	sys "sys"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

type msgErr int

type message struct {
	Err  msgErr      `json:"err"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data"`
}

const (
	mseqOK             msgErr = iota // 0
	mseqInternalServer               // 1
	mseqNoParam                      // 2
	mseqBadRequest
)
const mstrOK string = "ok"
const mstrInternalServer string = "内部系统错误"

// const mstrNoParam string = "缺少参数"
const mstrBadRequest string = "错误参数"

// const mstrNoUID string = "缺少uid参数"
// const mstrNoDocID string = "缺少docID参数"
func (msg message) setData(data interface{}) message {
	msg.Data = data
	return msg
}

func msgOK(msg ...string) message {
	m := message{Err: mseqOK}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrOK
	}
	return m
}
func msgInternalServer(msg ...string) message {
	m := message{Err: mseqInternalServer}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrInternalServer
	}
	return m
}
func msgNoFound(msg ...string) message {
	m := message{Err: mseqInternalServer}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrInternalServer
	}
	return m
}

//	func msgNoParam(msg ...string) message {
//		m := message{Err: mseqNoParam}
//		if len(msg) > 0 {
//			m.Msg = msg[0]
//		} else {
//			m.Msg = mstrNoParam
//		}
//		return m
//	}
func msgBadRequest(msg ...string) message {
	m := message{Err: mseqBadRequest}
	if len(msg) > 0 {
		m.Msg = msg[0]
	} else {
		m.Msg = mstrBadRequest
	}
	return m
}
func ok(g *gin.Context) {
	d := msgOK()
	log.Debug3f("\n%s", sys.JsonPrettyPrint(d))
	g.JSON(http.StatusOK, d)
}

func okData(g *gin.Context, obj any) {
	d := msgOK().setData(obj)
	log.Debug3f("\n%s", sys.JsonPrettyPrint(d))
	g.JSON(http.StatusOK, d)
}
func okImage(g *gin.Context, data bytes.Buffer) {
	name := g.Param("file")
	if !strings.Contains(name, ".") {
		badRequest(g)
		return
	}
	fotmat := strings.ToLower(strings.Split(name, ".")[1])
	switch fotmat {
	case "png":
		g.Data(http.StatusOK, "image/png", data.Bytes())
	case "jpg":
	case "jpeg":
		g.Data(http.StatusOK, "image/jpeg", data.Bytes())
	default:
		log.Errorf("未知图片类型,%s", fotmat)
	}
}

func badRequest(g *gin.Context) {
	g.AbortWithStatusJSON(http.StatusBadRequest, msgBadRequest())
}
func internalServerError(g *gin.Context) {
	g.AbortWithStatusJSON(http.StatusInternalServerError, msgInternalServer())
}
func notFound(g *gin.Context) {
	g.AbortWithStatusJSON(http.StatusNotFound, msgNoFound())
}
