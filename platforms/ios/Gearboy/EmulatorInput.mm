/*
 * Gearboy - Nintendo Game Boy Emulator
 * Copyright (C) 2012  Ignacio Sanchez
 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/
 *
 */

#include "EmulatorInput.h"
#import "Emulator.h"

EmulatorInput::EmulatorInput(Emulator* pEmulator)
{
    m_pEmulator = pEmulator;
    m_pInputCallbackController = new InputCallback<EmulatorInput> (this, &EmulatorInput::InputController);
    m_pInputCallbackButtons = new InputCallback<EmulatorInput> (this, &EmulatorInput::InputButtons);
}

EmulatorInput::~EmulatorInput()
{
    SafeDelete(m_pInputCallbackController);
    SafeDelete(m_pInputCallbackButtons);
}

void EmulatorInput::Init()
{
    for (int i = 0; i < 4; i++)
        m_bController[i] = false;
    
    CGFloat scale;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale=[[UIScreen mainScreen] scale];
    } else {
        scale=1; //only called on iPad.
    }
    
    BOOL retina;
    retina = (scale != 1);
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if (retina)
        {
            InputManager::Instance().AddCircleRegionEvent(280.0f, 325.0f, 30.0f, m_pInputCallbackButtons, 1, false);
            InputManager::Instance().AddCircleRegionEvent(233.0f, 345.0f, 30.0f, m_pInputCallbackButtons, 2, false);
            InputManager::Instance().AddCircleRegionEvent(182.0f, 390.0f, 25.0f, m_pInputCallbackButtons, 3, false);
            InputManager::Instance().AddCircleRegionEvent(128.0f, 390.0f, 25.0f, m_pInputCallbackButtons, 4, false);
            InputManager::Instance().AddCircleRegionEvent(57.0f, 342.0f, 50.0f, m_pInputCallbackController, 0, true);
        }
        else
        {

        }
    }
    else
    {
        if (retina)
        {
            
        }
        else
        {

        }
    }
}

void EmulatorInput::InputController(stInputCallbackParameter parameter, int id)
{
    //[m_pEmulator keyReleased:Gameboy_Keys::Up_Key];
    //[m_pEmulator keyReleased:Gameboy_Keys::Down_Key];
    //[m_pEmulator keyReleased:Gameboy_Keys::Right_Key];
    //[m_pEmulator keyReleased:Gameboy_Keys::Left_Key];
   
    bool bNewController[4];
    for (int i = 0; i < 4; i++)
        bNewController[i] = false;
    
    if (parameter.type != PRESS_END)
    {
        float length = parameter.vector.length();
        if (length >= 11.0f)
        {
            float angle = atan2f(parameter.vector.x, -parameter.vector.y) * 57.29577951f;
            
            bNewController[0] = ((angle >= 35.0f) && (angle <= 145.0f));
            bNewController[1] = ((angle <= -35.0f) && (angle >= -145.0f));
            bNewController[2] = ((angle >= -55.0f) && (angle <= 55.0f));
            bNewController[3] = ((angle >= 125.0f) || (angle <= -125.0f));
        }
    }
    
    for (int i = 0; i < 4; i++)
    {
        if (bNewController[i] != m_bController[i])
        {
            m_bController[i] = bNewController[i];
            
            Gameboy_Keys key;
            
            switch (i)
            {
                case 0:
                    key = Gameboy_Keys::Right_Key;
                    break;
                case 1:
                    key = Gameboy_Keys::Left_Key;
                    break;
                case 2:
                    key = Gameboy_Keys::Up_Key;
                    break;
                case 3:
                    key = Gameboy_Keys::Down_Key;
                    break;
            }
            
            if (m_bController[i])
            {
                Log("pulsando controller %d", key);
                [m_pEmulator keyPressed:key];
            }
            else
            {
                Log("soltando controller %d", key);
                [m_pEmulator keyReleased:key];
            }
        }
    }
}

void EmulatorInput::InputButtons(stInputCallbackParameter parameter, int id)
{
    Gameboy_Keys key;
    
    switch (id) {
        case 1:
            if (parameter.type == PRESS_START)
                Log("pulsado A");
            else if (parameter.type == PRESS_END)
                Log("solatado A");
            key = Gameboy_Keys::A_Key;
            break;
        case 2:
            if (parameter.type == PRESS_START)
                Log("pulsado B");
            else if (parameter.type == PRESS_END)
                Log("solatado B");
            key = Gameboy_Keys::B_Key;
            break;
        case 3:
            if (parameter.type == PRESS_START)
                Log("pulsado start");
            else if (parameter.type == PRESS_END)
                Log("solatado start");
            key = Gameboy_Keys::Start_Key;
            break;
        case 4:
            if (parameter.type == PRESS_START)
                Log("pulsado select");
            else if (parameter.type == PRESS_END)
                Log("solatado select");
            key = Gameboy_Keys::Select_Key;
            break;
    }
    
    if (parameter.type == PRESS_START)
        [m_pEmulator keyPressed:key];
    else if (parameter.type == PRESS_END)
        [m_pEmulator keyReleased:key];
    
}
