using System;
using System.IO;
using System.Threading;
using System.Diagnostics;
using SDL2;

namespace Chip8
{
	class Chip8
	{
		private const int CPU_INTERVAL = 1000 / 600;
		private const int TIMER_INTERVAL = 1000 / 60;
		
		private Stack stck = new .() ~ delete _;
		private Random rng = new .() ~ delete _;
		private Keyboard keyboard = new .() ~ delete _;
		private Display display = new .() ~ delete _;
		private Memory memory = new .() ~ delete _;

		private int? waitingOnKey = null;

		// Registers
		private uint16 pc;
		private uint16 I;
		private uint8 sp;
		private uint8 dt;
		private uint8 st;
		private uint8[] v = new .[0x10] ~ delete _;

		private void Reset()
		{
			this.pc = Memory.PROGRAM_START;
			this.I = 0x00;
			this.sp = 0x00;
			this.dt = 0x00;
			this.st = 0x00;

			Array.Clear(this.v, 0, 0x10);

			this.stck.Reset();
			this.display.Clear();
		}

		public Result<void> LoadGame(StringView path)
		{
			this.Reset();
			Try!(this.memory.LoadROM(path));
			
			String filename = scope .();
			Path.GetFileName(path, filename);
			this.display.ChangeWindowTitle(filename);

			return .Ok;
		}

		[Inline]	
		private void Advance()
		{
			this.pc += 2;
		}

		[Inline]
		private void JumpTo(uint16 addr)
		{
			this.pc = addr;
		}

		[Inline]
		private void SetFlagRegister(bool value)
		{
			this.v[0xF] = value ? 1 : 0;
		}

		[Inline]
		private void SetFlagRegister(int value)
		{
			this.v[0xF] = (value > 0) ? 1 : 0;

		}

		private Result<void> ExecuteNextInstruction()
		{
			let opcode = Try!(memory.ReadU16(this.pc));
			Advance();

			switch (Instruction.Parse(opcode))
			{
			case .CLS:
				display.Clear();
			case .RET:
				JumpTo(stck.Pop());
			case .SYS_ADDR(let addr):
				JumpTo(addr);
			case .JP_ADDR(let addr):
				JumpTo(addr);
			case .CALL_ADDR(let addr):
				stck.Push(pc);
				JumpTo(addr);
			case .SE_VX_BYTE(let x, let byte):
				if (v[x] == byte)
					Advance();
			case .SNE_VX_BYTE(let x, let byte):
				if (v[x] != byte)
					Advance();
			case .SE_VX_VY(let x, let y):
				if (v[x] == v[y])
					Advance();
			case .LD_VX_BYTE(let x, let byte):
				v[x] = byte;
			case .ADD_VX_BYTE(let x, let byte):
				v[x] += byte;
			case .LD_VX_VY(let x, let y):
				v[x] = v[y];
			case .OR_VX_VY(let x, let y):
				v[x] |= v[y];
			case .AND_VX_VY(let x, let y):
				v[x] &= v[y];
			case .XOR_VX_VY(let x, let y):
				v[x] ^= v[y];
			case .ADD_VX_VY(let x, let y):
				let sum = (uint16)v[x] + v[y];
				SetFlagRegister(sum > 0xFF);
				v[x] = (uint8)(sum & 0xFF);
			case .SUB_VX_VY(let x, let y):
				SetFlagRegister(v[x] > v[y]);
				v[x] -= v[y];
			case .SHR_VX_VY(let x, let y):
				SetFlagRegister(v[x] & 0x01);
				v[x] >>= 1;
			case .SUBN_VX_VY(let x, let y):
				SetFlagRegister(v[x] <= v[y]);
				v[x] = v[y] - v[x];
			case .SHL_VX_VY(let x, let y):
				SetFlagRegister(v[x] & 0x80);
				v[x] <<= 1;
			case .SNE_VX_VY(let x, let y):
				if (v[x] != v[y])
					Advance();
			case .LD_I_ADDR(let addr):
				I = addr;
			case .JP_V0_ADDR(let addr):
				JumpTo(v[0] + addr);
			case .RND_VX_BYTE(let x, let byte):
				v[x] = (uint8)rng.Next(0x100) & byte;
			case .DRW_VX_VY_NIBBLE(let x, let y, let nibble):
				let sprite = memory.ReadSlice(I, nibble);
				let collision = display.DrawSprite(v[x], v[y], sprite);
				SetFlagRegister(collision);
			case .SKP_VX(let x):
				if (keyboard.IsKeyPressed(v[x]))
					Advance();
			case .SKNP_VX(let x):
				if (!keyboard.IsKeyPressed(v[x]))
					Advance();
			case .LD_VX_DT(let x):
				v[x] = dt;
			case .LD_VX_K(let x):
				waitingOnKey = x;
			case .LD_DT_VX(let x):
				dt = v[x];
			case .LD_ST_VX(let x):
				st = v[x];
			case .ADD_I_VX(let x):
				I += v[x];
			case .LD_F_VX(let x):
				I = (uint16)v[x] * 5;
			case .LD_B_VX(let x):
				memory.WriteBCD(I, v[x]);
			case .LD_I_VX(let x):
				for (int i <= x)
				{
					memory[I + i] = v[i];
				}
			case .LD_VX_I(let x):
				for (int i <= x)
				{
					v[i] = memory[I + i];
				}
			case .Invalid:
				return .Err;
			}

			return .Ok;
		}

		public Result<void> Run()
		{
			Stopwatch sw = scope .();
			sw.Start();

			var currentTime = sw.ElapsedMilliseconds;
			var lastCpuUpdate = currentTime;
			var lastTimerUpdate = currentTime;

			while (!this.keyboard.ShouldQuit)
			{
				currentTime = sw.ElapsedMilliseconds;

				this.keyboard.Update();
				this.display.Render();

				if (currentTime - lastCpuUpdate > CPU_INTERVAL)
				{
					if (let waitingOnKey = this.waitingOnKey)
					{
						if (let key = this.keyboard.IsAnyKeyPressed())
						{
							this.v[(int)waitingOnKey] = key;
							this.waitingOnKey = null;
						}
					}
					else
					{
						Try!(this.ExecuteNextInstruction());
					}

					lastCpuUpdate = sw.ElapsedMilliseconds;
				}

				if (currentTime - lastTimerUpdate > TIMER_INTERVAL)
				{
					if (this.dt > 0)
					{
						this.dt--;
					}
					if (this.st > 0)
					{
						// Buzz
						this.st--;
					}

					lastTimerUpdate = sw.ElapsedMilliseconds;
				}

				Thread.Sleep(1);
			}

			return .Ok;
		}
	}
}
