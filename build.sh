echo "Cleaning up previous build..."

# Delete everything inside the bin folder except the folder itself
mkdir -p bin
rm -r bin/*

echo "Creating .love file..."

# Create a .love file
cp -r . /tmp/wave-shooter > /dev/null

(cd /tmp/wave-shooter/src && zip -9 -r ../../wave-shooter.love . > /dev/null)

mv /tmp/wave-shooter.love bin

echo "Downloading Love2D for Windows..."

# Download the Love2D binaries (windows32, will run on 64-bit windows as well as linux and macos)
wget -q -P bin https://github.com/love2d/love/releases/download/11.5/love-11.5-win32.zip

echo "Extracting Love2D for Windows..."

# Unzip the love2d binaries
unzip bin/love-11.5-win32.zip -d bin

echo "Building .exe file..."

# Create a .exe file from the .love file
cat bin/love-11.5-win32/love.exe bin/wave-shooter.love > bin/love-11.5-win32/game.exe

echo "Customizing..."
# Rename and remove objects
rm bin/love-11.5-win32.zip
rm bin/love-*-win32/love.exe
rm bin/love-*-win32/lovec.exe

# Change the icons, etc in the future

echo "Zipping..."

# Zip the game
(cd bin && zip -r wave-shooter-windows-x86_64.zip love-*-win32 > /dev/null)
rm -r bin/love*-win32

echo "Finished building for Windows!"
echo "Downloading Love2D for MacOS..."

# Download the Love2D binaries (macos)
wget -q -P bin https://github.com/love2d/love/releases/download/11.5/love-11.5-macos.zip

echo "Unzipping..."

# Unzip
mkdir bin/wave-shooter
unzip bin/love-11.5-macos.zip -d bin/wave-shooter
rm bin/love-11.5-macos.zip

echo "Copying files..."

# Copy the love file into the love.app/Contents/Resources folder
cp bin/wave-shooter.love bin/wave-shooter/love.app/Contents/Resources

# TODO: Change the icons, name, in the plist file

# Zip
echo "Zipping..."

# (cd bin && zip -r wave-shooter-macos.zip wave-shooter > /dev/null) # Commented out .zip, file was too big
(cd bin && tar -czvf wave-shooter-macos.tar.gz wave-shooter)
rm -r bin/wave-shooter

echo "Finished building for MacOS!"
echo "Creating Linux version..."

# Zip
cp build_assets/linux_readme.txt bin/readme.txt
# (cd bin && zip -r wave-shooter-linux-x86_64.zip wave-shooter.love readme.txt) # Used tar instead of zip to be more consistent and reduce file size
(cd bin && tar -czvf wave-shooter-linux-x86_64.tar.gz wave-shooter.love readme.txt)
rm bin/wave-shooter.love
rm bin/readme.txt

echo "Cleaning up..."

# Clean up
rm -rf /tmp/wave-shooter

echo "Done! All files are in the bin folder."
