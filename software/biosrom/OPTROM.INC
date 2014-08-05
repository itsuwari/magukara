;*****************************************
;PCIR��`
;*****************************************
PCIRS STRUC

PCIR_SIGN      DB 'PCIR'
PCIR_VENDOR_ID DW  ?
PCIR_DEVICE_ID DW  ?
PCIR_VPD       DW  ?
PCIR_LEN       DW  SIZE PCIRS
PCIR_REV       DB  00H
PCIR_CLASS_PROG DB  ?
PCIR_CLASS_SUB  DB  ?
PCIR_CLASS_BASE DB  ?
PCIR_IMAGE_LEN DW  ?
PCIR_REV_LVL   DW  ?
PCIR_CODE      DB  ?
PCIR_ID        DB  ?
PCIR_RSV       DB  2 DUP(?)

PCIRS ENDS

;*****************************************
;ROM Header Macro��`
;*****************************************
ROM_HEADER MACRO

        ORG     0
;---------------------------------------
;PCI�g��ROM�w�b�_�\����`
;---------------------------------------
ROM_SIGN    DW   0AA55H               ;PCI�g��ROM�w�b�_(�Œ�)
ROM_SIZE    DB   0                    ;�������T�C�Y(MAKEROM.COM���ݒ肷��)
ROM_JMP     LABEL FAR
            JMP  NEAR PTR &initCodeLabel ;�g��ROM�v���O�����ւ̃W�����v
ROM_DATA    DB   strROMData           ;�f�o�C�X�ŗL�̈�(�ő�18�o�C�g)
ROM_DATA_END LABEL BYTE
            ORG  18h
ROM_POINT   DW   PCIR                 ;PCI�f�[�^�\���ւ̃|�C���^(�����v�Z)
            .ERRNZ ROM_POINT LT ROM_DATA_END ;ROM_DATA��18�o�C�g�𒴂����ꍇ�G���[�ƂȂ�

;---------------------------------------
;PCI�{�[�h��/�g��ROM�o�[�W�����Ȃ�
;---------------------------------------
            DB   strROMName
;---------------------------------------
;PCI�f�[�^�\����`
;---------------------------------------
             ALIGN 4
PCIR        LABEL PCIRS
            PCIRS<,pcirVendorID,pcirDeviceID,pcirVPD,,,\
                   pcirClassBase,pcirClassSub,pcirClassProg,,\
                   pcirRevLvl,pcirCode,pcirID>

          ENDM

;*******************************************
; ROM_HEADER�}�N���p�f�t�H���g�l
;*******************************************
strROMData    CATSTR <'PCI Option ROM'>     ;�f�o�C�X�ŗL�̈�(�ő�18�o�C�g)
strROMName    CATSTR <'Option ROM Image',0> ;PCI�{�[�h��/�g��ROM�o�[�W�����Ȃ�
pcirVendorID  = 0000h
pcirDeviceID  = 0000h
pcirVPD       = 0000h
pcirClassProg = 00h
pcirClassSub  = 00h
pcirClassBase = 00h
pcirRevLvl    = 0000h
pcirCode      = 00h
pcirID        = 00h
initCodeLabel CATSTR <INIT_CODE>
