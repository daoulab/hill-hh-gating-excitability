function run_figure(name)
%RUN_FIGURE Launch one supplied figure from its own working directory.
% Example: run_figure('figure1'); run_figure('supplementary_figure5');
% Scientific scripts are unchanged; generated files may overwrite exports.
root = fileparts(mfilename('fullpath'));
folders = {'figure1','figure2','figure3','figure4','figure5','figure6','figure7', ...
    'supplementary_figure1','supplementary_figure2','supplementary_figure3', ...
    'supplementary_figure4','supplementary_figure5','supplementary_figure6'};
entries = {'figure1','figure2','figure3','figure4','figure5','figure6','figure7', ...
    'supplementry_figure1','supplementary_figure2','Supplementary_Figure_3', ...
    'Supplementary_Figure_4','Supplementary_Figure_5','Supplementary_Figure_6'};
if nargin ~= 1
    error('Provide a figure folder name; e.g. run_figure(''figure1'').');
end
idx = find(strcmp(char(name), folders), 1);
if isempty(idx), error('Unknown figure folder: %s', char(name)); end
old = pwd;
cleanup = onCleanup(@() cd(old)); %#ok<NASGU>
cd(fullfile(root, folders{idx}));
% A separate workspace protects cleanup from clear commands in scripts.
launch_entry(entries{idx});
end

function launch_entry(entry)
kind = exist(entry, 'file');
if kind ~= 2, error('Missing MATLAB entry point: %s', entry); end
if any(strcmp(entry, {'figure4','Supplementary_Figure_3', ...
        'Supplementary_Figure_4','Supplementary_Figure_5','Supplementary_Figure_6'}))
    feval(entry);
else
    run([entry '.m']);
end
end
