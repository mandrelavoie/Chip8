namespace Chip8
{
	enum Instruction
	{
		case CLS;
		case RET;
		case SYS_ADDR(uint16 addr);
		case JP_ADDR(uint16 addr);
		case CALL_ADDR(uint16 addr);
		case SE_VX_BYTE(uint8 vx, uint8 byte);
		case SNE_VX_BYTE(uint8 vx, uint8 byte);
		case SE_VX_VY(uint8 vx, uint8 vy);
		case LD_VX_BYTE(uint8 vx, uint8 byte);
		case ADD_VX_BYTE(uint8 vx, uint8 byte);
		case LD_VX_VY(uint8 vx, uint8 vy);
		case OR_VX_VY(uint8 vx, uint8 vy);
		case AND_VX_VY(uint8 vx, uint8 vy);
		case XOR_VX_VY(uint8 vx, uint8 vy);
		case ADD_VX_VY(uint8 vx, uint8 vy);
		case SUB_VX_VY(uint8 vx, uint8 vy);
		case SHR_VX_VY(uint8 vx, uint8 vy);
		case SUBN_VX_VY(uint8 vx, uint8 vy);
		case SHL_VX_VY(uint8 vx, uint8 vy);
		case SNE_VX_VY(uint8 vx, uint8 vy);
		case LD_I_ADDR(uint16 addr);
		case JP_V0_ADDR(uint16 addr);
		case RND_VX_BYTE(uint8 vx, uint8 byte);
		case DRW_VX_VY_NIBBLE(uint8 vx, uint8 vy, uint8 nibble);
		case SKP_VX(uint8 vx);
		case SKNP_VX(uint8 vx);
		case LD_VX_DT(uint8 vx);
		case LD_VX_K(uint8 vx);
		case LD_DT_VX(uint8 vx);
		case LD_ST_VX(uint8 vx);
		case ADD_I_VX(uint8 vx);
		case LD_F_VX(uint8 vx);
		case LD_B_VX(uint8 vx);
		case LD_I_VX(uint8 vx);
		case LD_VX_I(uint8 vx);
		case Invalid;

		public static Self Parse(uint16 opcode) {
			mixin NIBBLE(var idx) {
				(uint8)(opcode >> (idx*4) & 0x0F)
			}
			mixin X() {
				NIBBLE!(2)
			}
			mixin Y() {
				NIBBLE!(1)
			}
			mixin N() {
				NIBBLE!(0)
			}
			mixin NNN() {
				(opcode & 0x0FFF)
			}
			mixin KK() {
				(uint8)(opcode & 0xFF)
			}

			let nibbles = (NIBBLE!(3), NIBBLE!(2), NIBBLE!(1), NIBBLE!(0));

			switch (nibbles)
			{
			case (0x0, 0x0, 0xE, 0x0): return .CLS;
			case (0x0, 0x0, 0xE, 0xE): return .RET;
			case (0x0,   ?,   ?,   ?): return .SYS_ADDR(NNN!());
			case (0x1,   ?,   ?,   ?): return .JP_ADDR(NNN!());
			case (0x2,   ?,   ?,   ?): return .CALL_ADDR(NNN!());
			case (0x3,   ?,   ?,   ?): return .SE_VX_BYTE(X!(), KK!());
			case (0x4,   ?,   ?,   ?): return .SNE_VX_BYTE(X!(), KK!());
			case (0x5,   ?,   ?, 0x0): return .SE_VX_VY(X!(), Y!());
			case (0x6,   ?,   ?,   ?): return .LD_VX_BYTE(X!(), KK!());
			case (0x7,   ?,   ?,   ?): return .ADD_VX_BYTE(X!(), KK!());
			case (0x8,   ?,   ?, 0x0): return .LD_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0x1): return .OR_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0x2): return .AND_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0x3): return .XOR_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0x4): return .ADD_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0x5): return .SUB_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0x6): return .SHR_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0x7): return .SUBN_VX_VY(X!(), Y!());
			case (0x8,   ?,   ?, 0xE): return .SHL_VX_VY(X!(), Y!());
			case (0x9,   ?,   ?, 0x0): return .SNE_VX_VY(X!(), Y!());
			case (0xA,   ?,   ?,   ?): return .LD_I_ADDR(NNN!());
			case (0xB,   ?,   ?,   ?): return .JP_V0_ADDR(NNN!());
			case (0xC,   ?,   ?,   ?): return .RND_VX_BYTE(X!(), KK!());
			case (0xD,   ?,   ?,   ?): return .DRW_VX_VY_NIBBLE(X!(), Y!(), N!());
			case (0xE,   ?, 0x9, 0xE): return .SKP_VX(X!());
			case (0xE,   ?, 0xA, 0x1): return .SKNP_VX(X!());
			case (0xF,   ?, 0x0, 0x7): return .LD_VX_DT(X!());
			case (0xF,   ?, 0x0, 0xA): return .LD_VX_K(X!());
			case (0xF,   ?, 0x1, 0x5): return .LD_DT_VX(X!());
			case (0xF,   ?, 0x1, 0x8): return .LD_ST_VX(X!());
			case (0xF,   ?, 0x1, 0xE): return .ADD_I_VX(X!());
			case (0xF,   ?, 0x2, 0x9): return .LD_F_VX(X!());
			case (0xF,   ?, 0x3, 0x3): return .LD_B_VX(X!());
			case (0xF,   ?, 0x5, 0x5): return .LD_I_VX(X!());
			case (0xF,   ?, 0x6, 0x5): return .LD_VX_I(X!());
			}

			return .Invalid;
		}
	}
}
