using System;
using System.IO;

namespace Chip8
{
	class Memory
	{
		public const int PROGRAM_START = 0x200;

		const int MEMORY_SIZE = 0x1000;
		const int MAX_PROGRAM_SIZE = MEMORY_SIZE - PROGRAM_START;

		private uint8[] _inner = new .[MEMORY_SIZE] ( // First 75 bytes are the fonts
			0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
			0x20, 0x60, 0x20, 0x20, 0x70, // 1
			0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
			0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
			0x90, 0x90, 0xF0, 0x10, 0x10, // 4
			0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
			0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
			0xF0, 0x10, 0x20, 0x40, 0x40, // 7
			0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
			0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
			0xF0, 0x90, 0xF0, 0x90, 0x90, // A
			0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
			0xF0, 0x80, 0x80, 0x80, 0xF0, // C
			0xE0, 0x90, 0x90, 0x90, 0xE0, // D
			0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
			0xF0, 0x80, 0xF0, 0x80, 0x80, // F
		) ~ delete _; 
		private Span<uint8> content = Span<uint8>(_inner);

		public Result<void> LoadROM(StringView path)
		{
			var stream = scope FileStream();
		
			Try!(stream.Open(path, .Read));
			defer stream.Close();

			if (stream.Length >= MAX_PROGRAM_SIZE)
			{
				return .Err;
			}

			Try!(stream.TryRead(this.content.Slice(PROGRAM_START)));

			return .Ok;
		}

		public Span<uint8> Slice(int index, int len)
		{
			return this.content.Slice(index, len);
		}

		public void WriteBCD(int index, uint8 value)
		{
			this.content[index] = value / 100;
			this.content[index + 1] = (value % 100) / 10;
			this.content[index + 2] = value % 10;
		}

		public Result<uint16> ReadU16(int index)
		{
			let high = this.content[index];
			let low = this.content[index + 1];

			let result = ((uint16)high << 8) | low;

			return .Ok(result);
		}

		public uint8 this[int idx]
		{
			get
			{
				return this.content[idx];
			}
			set	mut
			{
				this.content[idx] = value;
			}
		}
	}
}
