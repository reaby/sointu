%define BPM 100

%include "sointu_header.inc"

BEGIN_PATTERNS
    PATTERN 64, 0, 0, 0, 68, 0, 0, 0,    66, 0, 0, 0,   69, 0, 0, 0,
    PATTERN 0, 68, 0, 0, 71, 0, 0, 0,    69, 0, 0, 0,   73, 0, 0, 0,
    PATTERN 0, 0, 71, 0, 75, 0, 0, 0,    73, 0, 0, 0,   76, 0, 0, 0,
END_PATTERNS

BEGIN_TRACKS
    TRACK VOICES(1),0
    TRACK VOICES(1),1
    TRACK VOICES(1),2
END_TRACKS

BEGIN_PATCH
    BEGIN_INSTRUMENT VOICES(3) ; Instrument0
        SU_ENVELOPE MONO,ATTAC(64),DECAY(64),SUSTAIN(64),RELEASE(64),GAIN(32)
        SU_ENVELOPE MONO,ATTAC(64),DECAY(64),SUSTAIN(64),RELEASE(64),GAIN(32)
        SU_OSCILLAT MONO,TRANSPOSE(88),DETUNE(64),PHASE(0),COLOR(128),SHAPE(64),GAIN(128),FLAGS(SINE)
        SU_OSCILLAT MONO,TRANSPOSE(88),DETUNE(64),PHASE(0),COLOR(128),SHAPE(64),GAIN(128),FLAGS(SINE)
        SU_MULP     STEREO
        SU_OUT      STEREO,GAIN(128)
    END_INSTRUMENT
END_PATCH

%include "sointu_footer.inc"
