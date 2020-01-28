let
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "dd94a849df69fe62fe2cb23a74c2b9330f1189ed"; # CHANGEME
    ref = "release-18.09";
  };
in
{ config, pkgs, ... }: {
  imports = [
    <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
    (import "${home-manager}/nixos")
  ];
  ec2.hvm = true;
  networking.hostName = "grace";
  nixpkgs.localSystem.system = "x86_64-linux";

  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = ["@wheel"];

  services.openssh.passwordAuthentication = false;

  users.users.chckyn = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyoDWC2sEK7fq2D0u/RA8l6gzmlv+DVKJUtDN2qZpC63GdWrvu/9Em5p4qLnC39wx7aHNvvUw/FAEUaLzfHIGVbRqYijggx/ffV5zovdpgPLliBfW9rpEBFNDPDwETS8MFXa9WF927bSHw4qGOHO5GTEuABCG2tcvyBXYL2aFoLgHqpzbf8ROrdsSMfnqf1bQKo86s7zT1Ey68hgdELCiIMN7uFFaG3+TtgW0AUIPbw5Nl0yRIIPf9F6L4d975ESu/udR54YXHTUaJhJwIyn9Lv/T/SEit/GwxePDN1p1XzCDNsM1aaa2xbSZpTH5KUHD81jrqb+XiuBMXDzBs5YJh chcel@8c859046b643.ant.amazon.com"
    ];
  };

  environment.systemPackages = with pkgs; [ vim clang-tools git ];

  home-manager.users.chckyn = {

    programs.git = {
      enable = true;
      userName  = "Charles Celerier";
      userEmail = "cceleri@cs.stanford.edu";
	  extraConfig = { core = { editor = "vim"; }; };
    };

    programs.vim = {
      enable = true;
      plugins = [ "vim-airline" "vim-autoformat" ];
      settings = {
	    ignorecase = true;
		mouse = "a";
	  };
      extraConfig = ''
let mapleader = " "
" Open a netrw buffer in the directory containing the file in the current
" buffer
nnoremap <leader>m :Explore <CR>

" Open a prompt to select a buffer
nnoremap <leader>b :ls<CR>:b<space>

" Configure Vim's default file browser NETRW
let g:netrw_banner = 0
let g:netrw_sizestyle = "H"
let g:netrw_winsize = 30
let g:netrw_liststyle = 3

colorscheme desert

" Center the cursor vertically
augroup VCenterCursor
  au!
  au BufEnter,WinEnter,WinNew,VimResized *,*.*
        \ let &scrolloff=winheight(win_getid())/2
augroup END

" Highlight the current line
hi CursorLine cterm=bold ctermbg=darkblue
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

au BufWrite * :Autoformat

" Enable vim-airline tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
      '';
    }; 
  };
}
