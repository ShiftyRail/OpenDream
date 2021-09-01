﻿using Content.Shared.Interface;
using Robust.Client.Input;
using Robust.Client.UserInterface;
using Robust.Client.UserInterface.Controls;

namespace Content.Client.Interface.Controls
{
    class ControlMap : InterfaceControl
    {
        public ScalingViewport Viewport { get; private set; }

        public ControlMap(ControlDescriptor controlDescriptor, ControlWindow window) : base(controlDescriptor, window)
        {
        }

        protected override Control CreateUIElement()
        {
            Viewport = new ScalingViewport
            {
                ViewportSize = (32 * 15, 32 * 15) ,
                MouseFilter = Control.MouseFilterMode.Stop
            };
            return new PanelContainer
            {
                StyleClasses = { "MapBackground" },
                Children = { Viewport }
            };
        }
    }
}