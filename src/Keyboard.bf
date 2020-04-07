using System;
using SDL2;

namespace Chip8
{
	class Keyboard
	{
		private static readonly SDL.Scancode[] KEYMAP = new .[]
		{
			SDL.Scancode.X,    // 0
			SDL.Scancode.Key1, // 1
			SDL.Scancode.Key2, // 2
			SDL.Scancode.Key3, // 3
			SDL.Scancode.Q,	   // 4
			SDL.Scancode.W,	   // 5
			SDL.Scancode.E,	   // 6
			SDL.Scancode.A,	   // 7
			SDL.Scancode.S,	   // 8
			SDL.Scancode.D,	   // 9
			SDL.Scancode.Z,	   // A
			SDL.Scancode.C,	   // B
			SDL.Scancode.Key4, // C
			SDL.Scancode.R,	   // D
			SDL.Scancode.F,	   // E
			SDL.Scancode.V,	   // F
		} ~ delete _;

		private bool* _state = null;
		private bool* State
		{
			get
			{
				if (this._state == null)
				{
					this._state = SDL.GetKeyboardState(null);
				}

				return this._state;
			}
		}

		public bool ShouldQuit { get; private set; }

		public void Update()
		{
			SDL.Event e;
			while (SDL.PollEvent(out e) != 0)
			{
				switch (e.type)
				{
				case .Quit:
					this.ShouldQuit = true;
				case .KeyDown:
					switch (e.key.keysym.scancode)
					{
					case .Escape:
						this.ShouldQuit = true;
					default:
					}
				default:
				}	
			}
		}

		public bool IsKeyPressed(uint8 key)
		{
			return this.State[(int)KEYMAP[key]];
		}

		public uint8? IsAnyKeyPressed() {
			for (uint8 i <= 0xF)
			{
				if (this.State[(int)KEYMAP[i]])
				{
					return i;
				} 
			}

			return null;
		}
	}
}
