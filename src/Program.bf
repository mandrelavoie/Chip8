using System;
using System.IO;

namespace Chip8
{
	class Program
	{
		public static int Main()
		{
			if (Run() case .Err)
			{
				Internal.FatalError("An error occurred..."); // Need to pass more information via the error type.
			}

			return 0;
		}

		private static Result<void> Run()
		{
			var romLocation = scope String();
			if (PickRom(romLocation) case .Err)
			{
				// Don't show an error message if the user just close the file dialog
				return .Ok;
			}

			let chip8 = scope Chip8();
			Try!(chip8.LoadGame(romLocation));

			Try!(chip8.Run());

			return .Ok;
		}

		private static Result<void> PickRom(String location)
		{
			var dialog = scope OpenFileDialog();
			dialog.Title = "Choose ROM to play";
			dialog.CheckFileExists = true;
			dialog.Multiselect = false;
			dialog.InitialDirectory = GetCurrentDirectory!();

			Try!(dialog.ShowDialog());

			dialog.FileNames[0].ToString(location);

			return .Ok;
		}

		private static mixin GetCurrentDirectory()
		{
			String exePath = scope:mixin .();
			Environment.GetExecutableFilePath(exePath);
			String exeDir = scope:mixin .();
			Path.GetDirectoryPath(exePath, exeDir);

			exeDir
		}
	}
}
