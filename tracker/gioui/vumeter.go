package gioui

import (
	"image"

	"gioui.org/op"
	"gioui.org/op/clip"
	"gioui.org/op/paint"
	"gioui.org/unit"
	"github.com/vsariola/sointu/tracker"
)

type VuMeter struct {
	AverageVolume tracker.Volume
	PeakVolume    tracker.Volume
	Range         float32
}

func (v VuMeter) Layout(gtx C) D {
	defer op.Offset(image.Point{}).Push(gtx.Ops).Pop()
	gtx.Constraints.Max.Y = gtx.Dp(unit.Dp(12))
	height := gtx.Dp(unit.Dp(6))
	for j := 0; j < 2; j++ {
		peakValue := float32(v.PeakVolume[j]) + v.Range
		if peakValue > 0 {
			x := int(peakValue/v.Range*float32(gtx.Constraints.Max.X) + 0.5)
			if x > gtx.Constraints.Max.X {
				x = gtx.Constraints.Max.X
			}
			color := vuMeterPeak
			if peakValue >= v.Range {
				color = vuMeterPeakClip
			}
			paint.FillShape(gtx.Ops, color, clip.Rect(image.Rect(0, 0, x, height)).Op())
		}
		value := float32(v.AverageVolume[j]) + v.Range
		if value > 0 {
			x := int(value/v.Range*float32(gtx.Constraints.Max.X) + 0.5)
			if x > gtx.Constraints.Max.X {
				x = gtx.Constraints.Max.X
			}
			color := vuMeterAvg
			if peakValue >= v.Range {
				color = vuMeterAvgClip
			}
			paint.FillShape(gtx.Ops, color, clip.Rect(image.Rect(0, 0, x, height)).Op())
		}

		valueMax := float32(v.PeakVolume[j]) + v.Range
		if valueMax > 0 {
			color := white
			if valueMax >= v.Range {
				color = errorColor
			}
			x := int(valueMax/v.Range*float32(gtx.Constraints.Max.X) + 0.5)
			if x > gtx.Constraints.Max.X {
				x = gtx.Constraints.Max.X
			}
			paint.FillShape(gtx.Ops, color, clip.Rect(image.Rect(x-1, 0, x, height)).Op())
		}
		op.Offset(image.Point{0, height}).Add(gtx.Ops)
	}
	return D{Size: gtx.Constraints.Max}
}
