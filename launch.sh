#!/bin/bash

. ./utils/config.sh
. ./utils/lib.sh


function main_menu()
{
    $OPTION
    clear
    get_logo
    echo " -----------------------------------------------------"
    echo "|               eXpOS NITC custom shell               |"
    echo "|                     Version ${VERSION}                     |"
    echo " -----------------------------------------------------"
    echo "WARNING: This script will not work if you didn't compile the project before."
    echo ""
    echo "1. Run XSM machine"
    echo "2. Compile and load OS"
    echo "3. Compile and load a expl program"
    echo "4. Compile and load routines"
    echo "5. Load everything"
    echo "6. Compile SPL program"
    echo "7. Compile EXPL program"
    echo "8. XFS interface"
    echo "9. Load a compiled xsm program (from: expl programs dir)"
    echo "10. Load a compiled xsm program (from: spl programs dir)"
    echo "11. Show current config"
    echo ""
    echo "Anything else will end the program."
    echo ""
    read -p "Choose your option: " OPTION
    if [[ OPTION -eq 1 ]]; then
        xsm_machine_menu
        return_to_menu
    elif [[ OPTION -eq 2 ]]; then
        compile_and_load_os
        return_to_menu
    elif [[ OPTION -eq 3 ]]; then
        compile_and_load_expl_program
        return_to_menu
    elif [[ OPTION -eq 4 ]]; then
        compile_and_load_routines
        return_to_menu
    elif [[ OPTION -eq 5 ]]; then
        full_load
        return_to_menu
    elif [[ OPTION -eq 6 ]]; then
        compile_spl_program
        return_to_menu
    elif [[ OPTION -eq 7 ]]; then
        compile_expl_program
        return_to_menu
    elif [[ OPTION -eq 8 ]]; then
        load_xfs_interface
        return_to_menu
    elif [[ OPTION -eq 9 ]]; then
        load_xsm_program_from_expl
        return_to_menu
    elif [[ OPTION -eq 10 ]]; then
        load_xsm_program_from_spl
        return_to_menu
    elif [[ OPTION -eq 11 ]]; then
        show_config
        return_to_menu
    fi
}

main_menu
