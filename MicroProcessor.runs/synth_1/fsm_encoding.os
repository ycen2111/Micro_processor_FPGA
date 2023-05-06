
 add_fsm_encoding \
       {Processor.CurrState} \
       { }  \
       {{00000000 000000} {00010000 000001} {00010001 000010} {00010010 000011} {00010011 000100} {00010100 000101} {00100000 000110} {00100001 000111} {00100010 001000} {00110000 001001} {00110001 001010} {00110010 001011} {01000000 001100} {01000001 001101} {01000010 001110} {01010000 001111} {01010001 010000} {01010010 010001} {01100000 010110} {01100001 010111} {01100010 011000} {01110000 011001} {01110001 011010} {01110010 011011} {01110011 011100} {10000000 011101} {10000001 011110} {10000010 011111} {10000011 100000} {10010000 100001} {10010001 100010} {10010010 100011} {10010011 100100} {11110000 010010} {11110001 010011} {11110010 010100} {11110011 010101} }

 add_fsm_encoding \
       {MouseTransmitter.Curr_State} \
       { }  \
       {{0000 0000} {0001 0001} {0010 0010} {0011 0011} {0100 0100} {0101 0101} {0110 0110} {0111 0111} {1000 1000} {1001 1001} }

 add_fsm_encoding \
       {MouseReceiver.Curr_State} \
       { }  \
       {{000 000} {001 001} {010 010} {011 011} {100 100} }

 add_fsm_encoding \
       {MouseMasterSM.Curr_State} \
       { }  \
       {{0000 0000} {0001 0001} {0010 0010} {0011 0011} {0100 0100} {0101 0101} {0110 0110} {0111 0111} {1000 1000} {1001 1001} {1010 1010} {1011 1011} {1100 1100} }