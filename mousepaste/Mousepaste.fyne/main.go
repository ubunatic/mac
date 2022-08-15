package main

import (
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

func main() {
	a := app.New()
	w := a.NewWindow("Mousepaste")

	hello := widget.NewLabel("Hello Mousepaste!")
	w.SetContent(container.NewVBox(
		hello,
		widget.NewButton("Test", func() {
			hello.SetText("It works!")
		}),
	))

	w.ShowAndRun()
}
