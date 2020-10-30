%define BPM 100

%include "sointu_header.inc"

BEGIN_PATTERNS
    PATTERN 64, HLD, HLD, HLD, HLD, HLD, HLD, HLD,  0, 0, 0, 0, 0, 0, 0, 0
END_PATTERNS

BEGIN_TRACKS
    TRACK   VOICES(1),0
END_TRACKS

BEGIN_PATCH
    BEGIN_INSTRUMENT VOICES(1) ; Instrument0
        SU_LOADVAL MONO,VALUE(96)
        SU_LOADVAL MONO,VALUE(128)
        SU_LOADVAL MONO,VALUE(0)
        SU_LOADVAL MONO,VALUE(96)   
        SU_MUL     STEREO
        SU_XCH     STEREO
        SU_POP     MONO
        SU_POP     MONO
        SU_OUT     STEREO,GAIN(128)
    END_INSTRUMENT
END_PATCH

%include "sointu_footer.inc"
