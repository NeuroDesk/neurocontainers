%% Store current working directory
cwd = pwd;
%% Download SPM12 r7771
unzip ("https://github.com/spm/spm12/archive/r7771.zip", cwd);
%% Patch SPM12
urlwrite ("https://raw.githubusercontent.com/spm/spm-docker/main/octave/spm12_r7771.patch", "spm12_r7771.patch");
system ("patch -p3 -d spm12-r7771 < spm12_r7771.patch");
%% Compile MEX files
cd (fullfile (cwd, "spm12-r7771", "src"));
system ("make PLATFORM=octave");
system ("make PLATFORM=octave install");
%% Add SPM12 to the function search path
addpath (fullfile (cwd, "spm12-r7771"));
cd (cwd);
%% Start SPM12
spm