using System;
using System.IO;

using SDL2;

namespace Chip8
{
	class Display
	{
		private const int32 WINDOW_WIDTH = 800;
		private const int32 WINDOW_HEIGHT = 400;
		private const String WINDOW_TITLE = "Chip8 Emulator";

		private const int BUFFER_WIDTH = 0x40;
		private const int BUFFER_HEIGHT = 0x20;
		private const int BUFFER_SIZE = BUFFER_WIDTH * BUFFER_HEIGHT;

		private const uint32 BACKGROUND = 0x1493A5;
		private const uint32 FOREGROUND = 0xF1EADC;

		private SDL.Window* window;
 		private SDL.Renderer* renderer;
		private SDL.Texture* screen;

		private bool shouldRedraw = false;

		public uint32[] pixels = new .[BUFFER_SIZE] ~ delete _;

		public this()
		{
			SDL.Init(.Video | .Events);

			this.window = SDL.CreateWindow(WINDOW_TITLE, .Undefined, .Undefined, WINDOW_WIDTH, WINDOW_HEIGHT, .Shown);
			this.renderer = SDL.CreateRenderer(window, -1, .Accelerated);

			this.screen = SDL.CreateTexture(this.renderer, (uint32)SDL.PIXELFORMAT_RGB888, (uint32)SDL.TextureAccess.Static, BUFFER_WIDTH, BUFFER_HEIGHT);
		}

		public ~this()
		{
			if (this.renderer != null)
			{
				SDL.DestroyRenderer(renderer);
			}

			if (this.window != null)
			{
				SDL.DestroyWindow(window);
			}
		}

		public void ChangeWindowTitle(StringView title)
		{
			SDL.SetWindowTitle(this.window, title.ToScopeCStr!());
		}

		private bool FlipPixel(int offset)
		{
			let previous = this.pixels[offset];
			this.pixels[offset]	= previous == FOREGROUND ? BACKGROUND : FOREGROUND;

			return previous == FOREGROUND;
		}

		public bool DrawSprite(int x, int y, Span<uint8> sprite)
		{
			var collision = false;

			for (int i < sprite.Length)
			{
				var lineOffset = {
					let line = (y + i) % BUFFER_HEIGHT;

					line * BUFFER_WIDTH
				};

				for (int j < 8)
				{
					let shouldFlip = (((sprite[i] >> (7 - j)) & 1) > 0);

					if (shouldFlip)
					{
						let rowOffset = (x + j) % BUFFER_WIDTH;
						collision |= FlipPixel(lineOffset + rowOffset);
					}
						
				}
			}

			this.shouldRedraw = true;

			return collision;
		}

		public void Render()
		{
			if (this.shouldRedraw)
			{
				SDL.UpdateTexture(this.screen, null, (void*)pixels.CArray(), BUFFER_WIDTH * sizeof(uint32));
				SDL.RenderCopy(this.renderer, this.screen, null, null);

				SDL.RenderPresent(this.renderer);

				this.shouldRedraw = false;
			}
		}

		public void Clear() {
			for (int i < BUFFER_SIZE)
			{
				this.pixels[i] = BACKGROUND;
			}

			this.shouldRedraw = true;
		}
	}
}
