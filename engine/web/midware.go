package web

import (
	"bytes"
	"fmt"
	"io"
	"strings"

	"github.com/tengfei-xy/whisperingtime/engine/modb"

	"github.com/gin-gonic/gin"
	log "github.com/tengfei-xy/go-log"
)

func getTid() gin.HandlerFunc {
	return func(g *gin.Context) {
		tid := g.Param("tid")
		toid, err := modb.GetTOIDFromTID(tid)
		if err != nil {
			log.Error(err)
			internalServerError(g)
			return
		}
		g.Set("toid", toid)
		g.Next()
	}
}

func getGid() gin.HandlerFunc {
	return func(g *gin.Context) {

		gid := g.Param("gid")
		if gid == "" {
			log.Error("gid is empty")
			badRequest(g)
			return
		}
		if strings.Contains(gid, "?") {
			gid = strings.Split(gid, "?")[0]
		}
		goid, err := modb.GetGOIDFromGID(gid)
		if err != nil {
			log.Error(err)
			internalServerError(g)
			return
		}

		g.Set("goid", goid)
		g.Next()
	}
}

func getTidAndGid() gin.HandlerFunc {
	return func(g *gin.Context) {

		tid := g.Param("tid")
		if tid == "" {
			log.Error("tid is empty")
			badRequest(g)
			return
		}
		toid, err := modb.GetTOIDFromTID(tid)
		if err != nil {
			log.Error(err)
			internalServerError(g)
			return
		}
		g.Set("toid", toid)

		gid := g.Param("gid")
		if gid == "" {
			log.Error("gid is empty")
			badRequest(g)
			return
		}
		goid, err := modb.GetGOIDFromGID(gid)
		if err != nil {
			log.Error(err)
			internalServerError(g)
			return
		}

		g.Set("goid", goid)
		g.Next()
	}
}

func getGidAndDid() gin.HandlerFunc {
	return func(g *gin.Context) {

		gid := g.Param("gid")
		if gid == "" {
			log.Error("gid is empty")
			badRequest(g)
			return
		}
		goid, err := modb.GetGOIDFromGID(gid)
		if err != nil {
			log.Error(err)
			internalServerError(g)
			return
		}

		g.Set("goid", goid)

		did := g.Param("did")
		if did == "" {
			log.Error("did is empty")
			badRequest(g)
			return
		}
		doid, err := modb.GetDOIDFromGOIDAndDID(goid, did)
		if err != nil {
			log.Error(err)
			internalServerError(g)
			return
		}
		g.Set("doid", doid)

		g.Next()
	}
}

func getBGJid() gin.HandlerFunc {
	return func(g *gin.Context) {
		bgjid := g.Param("bgjid")
		if bgjid == "" {
			log.Error("bgjid is empty")
			badRequest(g)
			return
		}

		bgjoid, err := modb.GetBGJOIDFromBGJID(bgjid)
		if err != nil {
			log.Error(err)
			internalServerError(g)
			return
		}

		g.Set("bgjoid", bgjoid)
		g.Next()
	}
}

// responseWriter 用于捕获响应内容
type responseWriter struct {
	gin.ResponseWriter
	body *bytes.Buffer
}

func (w responseWriter) Write(b []byte) (int, error) {
	w.body.Write(b)
	return w.ResponseWriter.Write(b)
}

func loggerMiddleware() gin.HandlerFunc {
	return func(g *gin.Context) {
		var requestInfo strings.Builder
		requestInfo.WriteString("========== REQUEST ==========\n")
		requestInfo.WriteString(fmt.Sprintf("%s %s\n", g.Request.Method, g.Request.URL.Path))

		if len(g.Request.URL.RawQuery) > 0 {
			requestInfo.WriteString(fmt.Sprintf("Query: %s\n", g.Request.URL.RawQuery))
		}

		requestInfo.WriteString("Headers:\n")
		for key, values := range g.Request.Header {
			for _, value := range values {
				requestInfo.WriteString(fmt.Sprintf("  %s: %s\n", key, value))
			}
		}

		var bodyBytes []byte
		if g.Request.Body != nil {
			bodyBytes, _ = io.ReadAll(g.Request.Body)
			g.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
		}

		if len(bodyBytes) > 0 {
			contentType := g.Request.Header.Get("Content-Type")
			if strings.Contains(contentType, "text") ||
				strings.Contains(contentType, "json") ||
				strings.Contains(contentType, "xml") ||
				contentType == "" {
				requestInfo.WriteString(fmt.Sprintf("Body:\n%s\n", string(bodyBytes)))
			} else {
				requestInfo.WriteString(fmt.Sprintf("Body: [%s, %d bytes]\n", contentType, len(bodyBytes)))
			}
		}
		requestInfo.WriteString("=============================")

		log.Debug3f("\n%s", requestInfo.String())

		// 使用自定义ResponseWriter捕获响应体
		writer := &responseWriter{
			ResponseWriter: g.Writer,
			body:           bytes.NewBufferString(""),
		}
		g.Writer = writer

		g.Next()

		var responseInfo strings.Builder
		responseInfo.WriteString("========== RESPONSE ==========\n")
		responseInfo.WriteString(fmt.Sprintf("%s %s | %d\n", g.Request.Method, g.Request.URL.Path, g.Writer.Status()))

		responseInfo.WriteString("Headers:\n")
		for key, values := range g.Writer.Header() {
			for _, value := range values {
				responseInfo.WriteString(fmt.Sprintf("  %s: %s\n", key, value))
			}
		}

		if writer.body.Len() > 0 {
			contentType := g.Writer.Header().Get("Content-Type")
			if strings.Contains(contentType, "text") ||
				strings.Contains(contentType, "json") ||
				strings.Contains(contentType, "xml") ||
				contentType == "" {
				responseInfo.WriteString(fmt.Sprintf("Body:\n%s\n", writer.body.String()))
			} else {
				responseInfo.WriteString(fmt.Sprintf("Body: [%s, %d bytes]\n", contentType, writer.body.Len()))
			}
		}
		responseInfo.WriteString("==============================")

		log.Debug2f("\n%s", responseInfo.String())
	}
}
