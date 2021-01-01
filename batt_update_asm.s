# first global function
.file "batt_update.c"

.text
  .global set_batt_from_ports
.type	set_batt_from_ports, @function
 # BATT_VOLTAGE_PORT : dx (w) (16bits) (short)
 # BATT_STATUS_PORT  : cl (b) (8bits) (char)
 # BATT_DISPLAY_PORT : r8d (l) (32bits) (int)

set_batt_from_ports:
  # coopy global variables
  movw BATT_VOLTAGE_PORT(%rip), %dx
  movb BATT_STATUS_PORT(%rip), %cl
  andq $0b1, %rcx
  movl BATT_DISPLAY_PORT(%rip), %r8d
  movw $0, %bx
  # if_batt_voltage_port<0{return 1}
  cmpw %bx, %dx
  jl ERROR

  movw %dx, (%rdi)  # set batt->volts = BATT_VOLTAGE_PORT
  jmp SET_PERCENT  # set voltage as percentage

SET_PERCENT:
  cmpw $3800, %dx
  jl NOT_FULL
  movw $100, 2(%rdi) # set the value in percent as 100%
  jmp CHECK_BATT_STATUS

NOT_FULL:
  cmpw $3000, %dx   # if dx is greater than 3000
  jg HAVE_BATTERY
  movw $0, 2(%rdi) # set the value in percent as 0%
  jmp CHECK_BATT_STATUS

HAVE_BATTERY:
  # batt->percent = (BATT_VOLTAGE_PORT - 3000)/8
  movw BATT_VOLTAGE_PORT(%rip), %dx
  movl %edx, %eax
  subw $3000, %ax
  movl $8, %esi
  cqto
  idivw %si
  movb %al, 2(%rdi)
  jmp CHECK_BATT_STATUS

CHECK_BATT_STATUS:
  cmpb $0b1, %cl
  je IS_PERCENT # set to percent mode
  movb $0, 3(%rdi)  # set volt mode
  movl $0, %eax     # return 0
  ret

IS_PERCENT:
  movb $0b1, %al
  movb %al, 3(%rdi) # set percent mode

  movl $0, %eax    # return 0
  ret

ERROR:
  movl $1, %eax # return 1
  ret

  # second global functions
.section .data
masks:
  .int 0b0111111
  .int 0b0000011
  .int 0b1101101
  .int 0b1100111
  .int 0b1010011
  .int 0b1110110
  .int 0b1111110
  .int 0b0100011
  .int 0b1111111
  .int 0b1110111

.text
  .global set_display_from_batt

 # *display = rsi (q)
 # temp_display = r8
 # masks = r9 (q)
 # batt_t struct = rdi (q)
 # batt->volts = rbx
 # batt->percent = rcx
 # batt->mode = rdx
 #
 # battery_right_vol = r10w (w)
 # battery_mid_vol = r11w (w)
 # battery_left_vol = r12w (w)
 # battery_right_per = r13w (w)
 # battery_mid_per = r14w (w)
 # battery_left_per = r15w (w)


set_display_from_batt:

  movw %di, %bx
  andq $0xFFFF, %rbx  # extract volts

  movq %rdi, %rcx
  sarq $16, %rcx
  andq $0xFF, %rcx  # to extract percentage

  movq %rdi, %r13    # extract mode
  sarq $24, %r13
  andq $0xFF, %r13

  leaq masks(%rip), %r9  # ptr to masks arr stored in r9

  movq $0, %r8 #   temp_display = 0b0;

set_display_masks_1:
 cmpb $0, %r13b  # if voltage
 je set_display_voltage_flag
 jmp set_display_percent_flag

set_display_voltage_flag:
 # *display |= 0b1<<22; //set the voltage signal
 movl $0b1, %eax
 sall $22, %eax
 orl %eax, %r8d
 # *display |= 0b1<<21; //set the decimal signal
 movl $0b1, %eax
 sall $21, %eax
 orl %eax, %r8d
 jmp batt_whole_vol

set_display_percent_flag:
 # *display |= 0b1<<23; //set the percentage signal
 movl $0b1, %eax
 sall $23, %eax
 orl %eax, %r8d
 jmp batt_set_per

batt_whole_vol:
  # get real value of the Volts to display
  movl %ebx, %eax
  movw $10, %r12w     # to divide by 10
  cqto
  idivw %r12w
  movl %eax, %r10d   # move the quotient to r10w

  cmpw $5, %dx     # if the reminder of battery_right_vol is >= 5
  jg batt_whole_vol_continue

  jmp batt_set_vol

batt_whole_vol_continue:
  cqto
  idivw %r12w
  movl %edx, %r10d # right voltage
  addl $1, %r10d   # add 1 to the quotient to round up

  cqto
  idivw %r12w
  movl %edx, %r11d  # middle voltage

  movl %eax, %r12d  # left voltage
  jmp set_display_vol_num

batt_set_vol:
  cqto
  idivw %r12w
  movl %edx, %r10d # right voltage

  cqto
  idivw %r12w
  movl %edx, %r11d  # middle voltage

  movl %eax, %r12d  # left voltage
  jmp set_display_vol_num

batt_set_per:
  movl %ecx, %eax
  movl $10, %r12d

  cqto
  idivl %r12d
  movl %edx, %r10d  # right percent

  cqto
  idivl %r12d
  movl %edx, %r11d # middle percent

  movl %eax, %r12d # left percent
  jmp set_display_per_num

set_display_vol_num:
 # *display |= mask[batt_right_vol]; //setting the right side number
 orl (%r9, %r10, 4), %r8d  # set right voltage

 cmpw $0, %r12w  # if batt_left_vol > 0
 jg set_display_masks_left_vol_good
 jmp set_display_masks_middle_vol

set_display_masks_left_vol_good:
 # *display |= mask[batt_left_vol]<<14;  //setting the left number
 movl (%r9, %r12, 4), %eax
 sall $14, %eax
 orl %eax, %r8d

set_display_masks_middle_vol:
 cmpw $0, %r11w  # if batt_middle_vol >= 0
 jge set_display_masks_middle_vol_good
 jmp set_display_masks_batt_pic

set_display_masks_middle_vol_good:
 # *display |= mask[batt_middle_vol]<<7;  //setting the middle number
 movl (%r9, %r11, 4), %eax
 sall $7, %eax
 orl %eax, %r8d
 jmp set_display_masks_batt_pic

set_display_per_num:
 # *display |= mask[batt_right_per]; //set the right side number
 orl (%r9, %r10, 4), %r8d # set right percent

 cmpw $0, %r12w  # if batt_left_per > 0
 jg set_display_masks_left_per_good
 jmp set_display_masks_middle_per_lb

set_display_masks_left_per_good:
 # *display |= mask[batt_left_per]<<14;  //setting the left number
 movl (%r9, %r12, 4), %eax
 sall $14, %eax
 orl %eax, %r8d

set_display_masks_middle_per_lg:
 cmpw $0, %r11w # if batt_middle_per >= 0
 jge set_display_masks_middle_per_good
 jmp set_display_masks_batt_pic

set_display_masks_middle_per_lb:
 cmpw $0, %r11w # if batt_middle_per > 0
 jg set_display_masks_middle_per_good
 jmp set_display_masks_batt_pic

set_display_masks_middle_per_good:
 # *display |= mask[batt_middle_per]<<7;  //setting the left number
 movl (%r9, %r11, 4), %eax
 sall $7, %eax
 orl %eax, %r8d

set_display_masks_batt_pic:
 cmpl $5, %ecx
 jge check_batt_lvl
 jmp to_return

check_batt_lvl: # to determine which bar to set for the battery level
 cmpl $29, %ecx
 jle set_1_bar
 cmpl $49, %ecx
 jle set_2_bar
 cmpl $69, %ecx
 jle set_3_bar
 cmpl $89, %ecx
 jle set_4_bar
 cmpl $89, %ecx
 jg set_5_bar

 jmp to_return
set_5_bar:
 #  *display |= 0b1<<24;
 movl $0b1, %eax
 sall $24, %eax
 orl %eax, %r8d

set_4_bar:
 #  *display |= 0b1<<25;
 movl $0b1, %eax
 sall $25, %eax
 orl %eax, %r8d

set_3_bar:
 #  *display |= 0b1<<26;
 movl $0b1, %eax
 sall $26, %eax
 orl %eax, %r8d

set_2_bar:
 #  *display |= 0b1<<27;
 movl $0b1, %eax
 sall $27, %eax
 orl %eax, %r8d

set_1_bar:
 #  *display |= 0b1<<28;
 movl $0b1, %eax
 sall $28, %eax
 orl %eax, %r8d
 jmp to_return

to_return:
 movl %r8d, (%rsi) # store ecx to the ptr address
 movl $0, %eax
 ret

 .text
 .global batt_update

 batt_update:
   # batt_t temp = %edi
   # int display = %edx

  pushq $0
  leaq (%rsp), %rdi

  call set_batt_from_ports # if(set_batt_from_ports(&temp) != 0)
  testl %eax, %eax # check for error
  jne error
  movl $0, %edx
  movl (%rsp), %edi
  popq %r8
  pushq $0

  leaq (%rsp), %rsi
  call set_display_from_batt
  cmpq $1, %rax
  je error

  movl (%rsp), %edx
  movl %edx, BATT_DISPLAY_PORT(%rip) # BATT_DISPLAY_PORT = display;
  popq %r8

  movq $0, %rax
  ret
 error:
   popq %r8

   movl $1, %eax
   ret
