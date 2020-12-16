package bridge_test

import (
	"bytes"
	"encoding/binary"
	"io/ioutil"
	"path"
	"runtime"
	"testing"

	"github.com/vsariola/sointu"
	"github.com/vsariola/sointu/bridge"
	// TODO: test the song using a mocks instead
)

const BPM = 100
const SAMPLE_RATE = 44100
const TOTAL_ROWS = 16
const SAMPLES_PER_ROW = SAMPLE_RATE * 4 * 60 / (BPM * 16)

const su_max_samples = SAMPLES_PER_ROW * TOTAL_ROWS

// const bufsize = su_max_samples * 2

func TestPlayer(t *testing.T) {
	patch := sointu.Patch{
		Instruments: []sointu.Instrument{sointu.Instrument{1, []sointu.Unit{
			sointu.Unit{Type: "envelope", Parameters: map[string]int{"stereo": 0, "attack": 32, "decay": 32, "sustain": 64, "release": 64, "gain": 128}},
			sointu.Unit{Type: "oscillator", Parameters: map[string]int{"stereo": 0, "transpose": 64, "detune": 64, "phase": 0, "color": 96, "shape": 64, "gain": 128, "type": sointu.Sine, "lfo": 0, "unison": 0}},
			sointu.Unit{Type: "mulp", Parameters: map[string]int{"stereo": 0}},
			sointu.Unit{Type: "envelope", Parameters: map[string]int{"stereo": 0, "attack": 32, "decay": 32, "sustain": 64, "release": 64, "gain": 128}},
			sointu.Unit{Type: "oscillator", Parameters: map[string]int{"stereo": 0, "transpose": 72, "detune": 64, "phase": 64, "color": 64, "shape": 96, "gain": 128, "type": sointu.Sine, "lfo": 0, "unison": 0}},
			sointu.Unit{Type: "mulp", Parameters: map[string]int{"stereo": 0}},
			sointu.Unit{Type: "out", Parameters: map[string]int{"stereo": 1, "gain": 128}},
		}}}}
	patterns := [][]byte{{64, 0, 68, 0, 32, 0, 0, 0, 75, 0, 78, 0, 0, 0, 0, 0}}
	tracks := []sointu.Track{sointu.Track{1, []byte{0}}}
	song := sointu.Song{BPM: 100, Patterns: patterns, Tracks: tracks, Patch: patch, Output16Bit: false, Hold: 1}
	synth, err := bridge.Synth(patch)
	if err != nil {
		t.Fatalf("Compiling patch failed: %v", err)
	}
	buffer, err := sointu.Play(synth, song)
	if err != nil {
		t.Fatalf("Render failed: %v", err)
	}
	_, filename, _, _ := runtime.Caller(0)
	expectedb, err := ioutil.ReadFile(path.Join(path.Dir(filename), "..", "tests", "expected_output", "test_oscillat_sine.raw"))
	if err != nil {
		t.Fatalf("cannot read expected: %v", err)
	}
	var createdbuf bytes.Buffer
	err = binary.Write(&createdbuf, binary.LittleEndian, buffer)
	if err != nil {
		t.Fatalf("error converting buffer: %v", err)
	}
	createdb := createdbuf.Bytes()
	if len(createdb) != len(expectedb) {
		t.Fatalf("buffer length mismatch, got %v, expected %v", len(createdb), len(expectedb))
	}
	for i, v := range createdb {
		if expectedb[i] != v {
			t.Fatalf("byte mismatch @ %v, got %v, expected %v", i, v, expectedb[i])
		}
	}
}