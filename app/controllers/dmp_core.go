package controllers

import (
	"bufio"
	"bytes"
	"encoding/base64"
	"encoding/json"
	"github.com/revel/revel"
	"github.com/satori/go.uuid"
	"net/http"
	"os"
	"reflect"
	"time"
)

type DmpCore struct {
	*revel.Controller
}

func (h DmpCore) Pixel() revel.Result {
	audience_id := h.ProcessCookie()
	h.ProcessLog(audience_id)
	h.Response.ContentType = "image/gif"
	data, _ := base64.StdEncoding.DecodeString("R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7")
	return h.RenderBinary(bytes.NewReader(data), "pixel.png", revel.Inline, time.Now())
}

func (h DmpCore) BuildUniqueId() string {
	return uuid.NewV4().String() + "-" + uuid.NewV4().String()
}

func (h DmpCore) ProcessCookie() string {
	audience_cookie, _ := h.Request.Cookie("AudienceID")
	audience_id := ""
	if reflect.ValueOf(audience_cookie).IsNil() {
		audience_id = h.BuildUniqueId()
		revel.TRACE.Printf("Cookieを保持していないため新規にCookie[%s]を割り当てます", audience_id)
	} else {
		audience_id = audience_cookie.Value
		revel.TRACE.Printf("Cookie[%s]を保有しています。有効期限の延長のみ行います。", audience_id)
	}
	cookie := http.Cookie{Name: "AudienceID", Value: audience_id, Domain: revel.Config.StringDefault("hostname", "micro-dmp.jp"), Path: "/", Expires: time.Now().AddDate(1, 0, 0)}
	h.SetCookie(&cookie)
	return audience_id
}

func (h DmpCore) ProcessLog(audience_id string) {
	log_data := h.BuildLogData()
	log_data["AudienceId"] = audience_id
	json_log, _ := json.Marshal(log_data)
	revel.TRACE.Printf("Log Data: %s", json_log)

	var writer *bufio.Writer
	filepath := revel.Config.StringDefault("access_log.filepath", "/tmp")
	filepath = filepath + "/audience-" + time.Now().Format("20060102") + ".log.json"
	file, _ := os.OpenFile(filepath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	writer = bufio.NewWriter(file)
	writer.Write(json_log)
	writer.WriteString("\n")
	writer.Flush()
}

func (h DmpCore) BuildLogData() map[string]string {
	log_data := make(map[string]string)
	log_data["Timestamp"] = time.Now().Format("2006-01-02 15:04:05")
	log_data["Url"] = h.Request.Referer()
	log_data["UserAgent"] = h.Request.UserAgent()
	if len(h.Request.Header["X-Forwarded-For"]) > 0 {
		log_data["RemoteAddr"] = h.Request.Header["X-Forwarded-For"][0]
	} else {
		log_data["RemoteAddr"] = ""
	}
	if len(h.Request.Header["Accept-Language"]) > 0 {
		log_data["Lang"] = h.Request.Header["Accept-Language"][0]
	} else {
		log_data["Lang"] = ""
	}
	if len(h.Request.URL.Query()["title"]) > 0 {
		log_data["Title"] = h.Request.URL.Query()["title"][0]
	} else {
		log_data["Title"] = ""
	}
	if len(h.Request.URL.Query()["referrer"]) > 0 {
		log_data["Referer"] = h.Request.URL.Query()["referrer"][0]
	} else {
		log_data["Referer"] = ""
	}
	if len(h.Request.URL.Query()["display_size"]) > 0 {
		log_data["DisplaySize"] = h.Request.URL.Query()["display_size"][0]
	} else {
		log_data["DisplaySize"] = ""
	}
	if len(h.Request.URL.Query()["window_size"]) > 0 {
		log_data["WindowSize"] = h.Request.URL.Query()["window_size"][0]
	} else {
		log_data["WindowSize"] = ""
	}
	return log_data
}
