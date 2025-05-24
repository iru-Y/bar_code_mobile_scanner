import time
import pyautogui
import os

pyautogui.FAILSAFE = False
pyautogui.PAUSE = 0.1

OK_BUTTON_IMAGE = 'ok_button.png'

def carregar_todos_codigos(arquivo):
    with open(arquivo, "r") as f:
        return [linha.strip() for linha in f if linha.strip()]

def clicou_no_botao_ok(timeout=2, confidence=0.9):
  
    fim = time.time() + timeout
    while time.time() < fim:
        pos = pyautogui.locateOnScreen(OK_BUTTON_IMAGE, confidence=confidence)
        if pos:
            pyautogui.click(pyautogui.center(pos))
            return True
        time.sleep(0.2)
    return False

def digitar_codigos(codigos):
    print("Posicione o cursor no campo de edição. Começando em 5s…")
    time.sleep(5)

    for codigo in codigos:
        try:
            pyautogui.write(codigo)
            pyautogui.press("enter")
            time.sleep(1)
            clicou_no_botao_ok()
        except Exception as e:
            print(f"Erro ao processar {codigo}: {e}")
        time.sleep(0.1)

if __name__ == "__main__":
    if not os.path.exists(OK_BUTTON_IMAGE):
        print(f"ERRO: não achei '{OK_BUTTON_IMAGE}'. "
              "Coloque aí a imagem do botão de diálogo.")
        exit(1)

    codigos = carregar_todos_codigos("produtos.txt")
    digitar_codigos(codigos)
