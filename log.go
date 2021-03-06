package kapacitor

import (
	"fmt"
	"log"
	"strings"

	"github.com/influxdata/kapacitor/pipeline"
	"github.com/influxdata/kapacitor/wlog"
)

type LogNode struct {
	node
	level  wlog.Level
	prefix string
}

// Create a new  LogNode which logs all data it receives
func newLogNode(et *ExecutingTask, n *pipeline.LogNode, l *log.Logger) (*LogNode, error) {
	level, ok := wlog.StringToLevel[strings.ToUpper(n.Level)]
	if !ok {
		return nil, fmt.Errorf("invalid log level %s", n.Level)
	}
	nn := &LogNode{
		node:   node{Node: n, et: et, logger: l},
		level:  level,
		prefix: n.Prefix,
	}
	nn.node.runF = nn.runLog
	return nn, nil
}

func (s *LogNode) runLog([]byte) error {
	key := fmt.Sprintf("%c! %s", wlog.ReverseLevels[s.level], s.prefix)
	switch s.Wants() {
	case pipeline.StreamEdge:
		for p, ok := s.ins[0].NextPoint(); ok; p, ok = s.ins[0].NextPoint() {
			s.logger.Println(key, p)
			for _, child := range s.outs {
				err := child.CollectPoint(p)
				if err != nil {
					return err
				}
			}
		}
	case pipeline.BatchEdge:
		for b, ok := s.ins[0].NextBatch(); ok; b, ok = s.ins[0].NextBatch() {
			s.logger.Println(key, b)
			for _, child := range s.outs {
				err := child.CollectBatch(b)
				if err != nil {
					return err
				}
			}
		}
	}
	return nil
}
