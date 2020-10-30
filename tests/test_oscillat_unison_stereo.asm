%define BPM 100

%include "sointu_header.inc"

BEGIN_PATTERNS
    PATTERN 64, 0, 68, 0, 32, 0, 0, 0,  75, 0, 78, 0,   0, 0, 0, 0,
END_PATTERNS

BEGIN_TRACKS
    TRACK   VOICES(1),0
END_TRACKS

BEGIN_PATCH
    BEGIN_INSTRUMENT VOICES(1) ; Instrument0        
        SU_ENVELOPE STEREO, ATTAC(32),DECAY(32),SUSTAIN(64),RELEASE(64),GAIN(128)
        SU_OSCILLAT STEREO, TRANSPOSE(64),DETUNE(0),PHASE(64),COLOR(128),SHAPE(64),GAIN(32), FLAGS(TRISAW + UNISON4)        
        SU_MULP     STEREO        
        SU_OUT      STEREO, GAIN(128)
    END_INSTRUMENT
END_PATCH

%include "sointu_footer.inc"
