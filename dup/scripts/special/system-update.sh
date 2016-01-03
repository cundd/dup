#!/bin/bash
pacman -Syu --noconfirm;
pacman -Rns --noconfirm $(pacman -Qtdq);
