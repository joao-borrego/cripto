.data:00000000 31 c0                            xor    eax,eax
.data:00000002 b0 46                            mov    al,0x46
.data:00000004 31 db                            xor    ebx,ebx
.data:00000006 31 c9                            xor    ecx,ecx
.data:00000008 cd 80                            int    0x80
.data:0000000a eb 16                            jmp    0x00000022
.data:0000000c 5b                               pop    ebx
.data:0000000d 31 c0                            xor    eax,eax
.data:0000000f 88 43 07                         mov    BYTE PTR [ebx+0x7],al
.data:00000012 89 5b 08                         mov    DWORD PTR [ebx+0x8],ebx
.data:00000015 89 43 0c                         mov    DWORD PTR [ebx+0xc],eax
.data:00000018 b0 0b                            mov    al,0xb
.data:0000001a 8d 4b 08                         lea    ecx,[ebx+0x8]
.data:0000001d 8d 53 0c                         lea    edx,[ebx+0xc]
.data:00000020 cd 80                            int    0x80
.data:00000022 e8 e5 ff ff ff                   call   0x0000000c
.data:00000027 2f                               das    
.data:00000028 62 69 6e                         bound  ebp,QWORD PTR [ecx+0x6e]
.data:0000002b 2f                               das    
.data:0000002c 73 68                            jae    0x00000096