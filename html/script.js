const messagesContainer = document.getElementById('chat-messages');
const inputArea = document.getElementById('input-area');
const chatInput = document.getElementById('chat-input');
const suggestionsContainer = document.getElementById('suggestions');
const commandHelpContainer = document.getElementById('command-help'); 

let allCommandsData = []; 

let messagesHideTimeout = null; 
const HIDE_DELAY = 5000; 
let isInputOpen = false; 
let currentConfig = { 
    enableOOC: true 
};

let enableDebugLogs = false;

let messageHistory = [];
let historyIndex = -1;
let currentInputValue = "";

function debugLog(...args) {
    if (enableDebugLogs) {
        console.log("[Chat][DEBUG][JS]", ...args);
    }
}

function debugWarn(...args) {
    if (enableDebugLogs) {
        console.warn("[Chat][DEBUG][JS]", ...args);
    }
}

function debugError(...args) {
    if (enableDebugLogs) {
        console.error("[Chat][DEBUG][JS]", ...args);
    }
}

function showMessagesAndSetHideTimeout() {
    messagesContainer.classList.add('active');
    clearTimeout(messagesHideTimeout);

    if (!isInputOpen) {
        messagesHideTimeout = setTimeout(() => {
            messagesContainer.classList.remove('active');
        }, HIDE_DELAY);
    }
}

function setInputAreaActive(active) {
    if (active) {
        inputArea.classList.add('active');
        messagesContainer.classList.add('active');
        clearTimeout(messagesHideTimeout);
    } else {
        inputArea.classList.remove('active');
        showMessagesAndSetHideTimeout();
    }
}

function updateSuggestionButtons(commands) {
    suggestionsContainer.innerHTML = '';
    let hasSuggestions = false; 

    if (commands && commands.length > 0) {
        commands.forEach(cmd => {
            const cmdName = Array.isArray(cmd) ? cmd[0] : cmd.name;
            if (cmdName) {
                const button = document.createElement('button');
                button.textContent = "/" + cmdName;
                button.onclick = function() {
                    chatInput.value = "/" + cmdName + " ";
                    chatInput.focus();
                    suggestionsContainer.style.display = 'none';
                };
                suggestionsContainer.appendChild(button);
                hasSuggestions = true;
            }
        });
    }

    return hasSuggestions;
}

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'chatDurumu') {
        const inputArea = document.getElementById('input-area');
        const messagesContainer = document.getElementById('chat-messages');
        const suggestionsContainer = document.getElementById('suggestions');

        if (inputArea) {
            debugLog("chatDurumu: inputArea bulundu. Durum:", data.durum);
            inputArea.classList.toggle('active', data.durum);
        } else {
            debugError("chatDurumu: inputArea bulunamadı!");
        }
        
        if (messagesContainer) {
            messagesContainer.classList.toggle('active', data.durum);
        }

        if (suggestionsContainer) {
            if (data.durum) {
                suggestionsContainer.style.display = 'none';
            } else {
                suggestionsContainer.style.display = 'none';
            }
        }

        if (data.durum) {
            isInputOpen = true;
            clearTimeout(messagesHideTimeout);
            setTimeout(() => {
                if (chatInput) { 
                    chatInput.focus();
                }
            }, 50); 
        } else {
             isInputOpen = false;
             showMessagesAndSetHideTimeout(); 
        }
    } else if (data.type === 'configUpdate') {
        debugLog("Config Update alındı:", data.config);
        currentConfig = { ...currentConfig, ...data.config };
        updateSuggestionButtons(allCommandsData);
        if (data.config.enableOOC !== undefined) {
        }
        if (data.config.enableDebugLogs !== undefined) {
            enableDebugLogs = data.config.enableDebugLogs;
            debugLog("Debug logları " + (enableDebugLogs ? "aktif" : "pasif") + " hale getirildi.");
        }
    } else if (data.type === 'updateSuggestions') {
        allCommandsData = data.commands || [];
        updateSuggestionButtons(allCommandsData);
    } else if (data.type === 'mesajEkle') {
        debugLog("mesajEkle alındı. Ham mesaj:", data.mesaj, "Renk:", data.renk);

        const messageElement = document.createElement('div');
        messageElement.classList.add('chat-message');

        const now = new Date();
        const timeString = `${now.getHours().toString().padStart(2, '0')}:${now.getMinutes().toString().padStart(2, '0')}`;

        let prefixContent = '';
        let prefixClass = '';
        let playerName = 'Bilinmeyen';
        let mainContent = '';
        let fullMessage = data.mesaj || '';

        const prefixMatch = fullMessage.match(/^\s*\[(.*?)\]\s*(.*)/);
        let remainingMessage = fullMessage;
        let prefixText = '';

        if (prefixMatch && prefixMatch[1]) {
            prefixText = prefixMatch[1].toUpperCase();
            remainingMessage = prefixMatch[2] || '';

            if (prefixText === 'ME') {
                prefixContent = `<span class="text-prefix">ME</span>`;
                prefixClass = 'prefix-me';
            } else if (prefixText === 'DO') {
                prefixContent = `<span class="text-prefix">DO</span>`;
                prefixClass = 'prefix-do';
            } else {
                prefixContent = `<span class="text-prefix">${prefixText}</span>`; 
                prefixClass = 'prefix-ooc';
            }
        } else {
            prefixClass = 'prefix-none';
            remainingMessage = fullMessage;
        }

        remainingMessage = remainingMessage.trim();
        if (prefixText === 'ME' || prefixText === 'DO') {
             const meDoMatch = remainingMessage.match(/^\*\s(?:\S+\s)?(\S.*?)\s+(.*)/); 
             if(meDoMatch && meDoMatch[1] && meDoMatch[2]) {
                playerName = meDoMatch[1].trim();
                mainContent = meDoMatch[2].replace(/\.?$/, '');
             } else {
                 playerName = prefixText; 
                 mainContent = remainingMessage;
             }
        } else if (prefixText === 'OOC') {
            const oocMatch = remainingMessage.match(/^\s*\[\d+\]\s(.*?):\s*(.*)/);
            if (oocMatch && oocMatch[1] && oocMatch[2]) {
                playerName = oocMatch[1].trim();
                mainContent = oocMatch[2];
            } else {
                playerName = "OOC";
                mainContent = remainingMessage;
            }
        } else {
            playerName = prefixText || "Sistem";
            mainContent = remainingMessage;
        }

        messageElement.innerHTML = `
            <span class="message-timestamp">${timeString}</span>
            <div class="message-content-wrapper">
                <div class="message-header">
                    ${prefixContent ? `<span class="prefix-container ${prefixClass}">${prefixContent}</span>` : ''}
                    <span class="player-name">${playerName}</span>
                </div>
                <div class="message-body">${mainContent}</div>
            </div>
        `;

        messagesContainer.appendChild(messageElement);
        scrollChatToBottom();
        showMessagesAndSetHideTimeout();
    
    } else if (data.type === 'inputHazirla') {
    } else if (data.type === 'chatTemizle') {
        messagesContainer.innerHTML = '';
    } else if (data.type === 'fontSizeAyarla') {
        messagesContainer.style.fontSize = data.boyut + 'px';
    } else if (data.type === 'showHeadActionUI') {
        debugLog("showHeadActionUI alındı. ID:", data.id, "X:", data.screenX, "Y:", data.screenY);
        if (!headActionContainer) {
            debugError("headActionContainer bulunamadı!");
            return;
        }
        const existingElement = document.getElementById(data.id);
        if (existingElement) {
            debugWarn("Mevcut head UI elementi bulundu, kaldırılıyor:", data.id);
            existingElement.remove(); 
        }
        debugLog("Element eklendi:", element);
        setTimeout(() => {
            element.classList.add('visible');
            debugLog("Element görünür yapıldı:", data.id);
        }, 10); 
    } else if (data.type === 'hideHeadActionUI') {
        debugLog("hideHeadActionUI alındı. ID:", data.id);
        const elementToRemove = document.getElementById(data.id);
        if (elementToRemove) {
           elementToRemove.classList.remove('visible'); 
           debugLog("Element görünmez yapıldı:", data.id);
           setTimeout(() => {
                if (elementToRemove.parentNode === headActionContainer) {
                    headActionContainer.removeChild(elementToRemove);
                    debugLog("Element DOM'dan kaldırıldı:", data.id);
                }
            }, 300); 
        } else {
             debugWarn("Kaldırılacak element bulunamadı:", data.id);
        }
    }
});

suggestionsContainer.addEventListener('click', (event) => {
    if (event.target.classList.contains('suggestion-button')) {
        const command = event.target.getAttribute('data-command');
        chatInput.value = command;
        chatInput.focus();
        isInputOpen = true;
        setInputAreaActive(true);
    }
});

chatInput.addEventListener('input', function() {
    const value = this.value;
    commandHelpContainer.style.display = 'none';
    commandHelpContainer.textContent = '';

    if (!value || !value.startsWith('/')) {
        suggestionsContainer.style.display = 'none'; 
        return;
    }
    
    const searchTerm = value.substring(1).toLowerCase();
    
    if (searchTerm.length === 0) { 
        suggestionsContainer.style.display = 'none';
        return;
    }

    const filteredCommands = allCommandsData.filter(cmd => {
        const cmdName = Array.isArray(cmd) ? cmd[0] : cmd.name;
        return cmdName && cmdName.toLowerCase().startsWith(searchTerm);
    });
        
    const suggestionsFound = updateSuggestionButtons(filteredCommands.slice(0, 10)); 
    suggestionsContainer.style.display = suggestionsFound ? 'flex' : 'none';

    if (filteredCommands.length > 0) {
        const firstMatch = filteredCommands[0];
        const firstMatchName = Array.isArray(firstMatch) ? firstMatch[0] : firstMatch.name;
        if (firstMatchName && firstMatchName.toLowerCase() === searchTerm) {
            const helpText = firstMatch.help;
            if (helpText) {
                commandHelpContainer.textContent = `Kullanım: /${firstMatchName} ${helpText}`;
                commandHelpContainer.style.display = 'block';
            }
        }
    }
});

chatInput.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
        event.preventDefault();
        const message = chatInput.value.trim();
        if (message) {
            if (messageHistory.length === 0 || messageHistory[messageHistory.length - 1] !== message) {
                messageHistory.push(message);
            }
            fetch(`https://${GetParentResourceName()}/mesajGonder`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                body: JSON.stringify({ message: message })
            }).catch(e => debugError("/mesajGonder fetch hatasi:", e));
        }
        chatInput.value = '';
        historyIndex = messageHistory.length;
        currentInputValue = "";
        fetch(`https://${GetParentResourceName()}/kapat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        }).catch(e => debugError("/kapat fetch hatasi:", e));
    } else if (event.key === 'Escape') {
        event.preventDefault();
        chatInput.value = '';
        historyIndex = messageHistory.length;
        currentInputValue = "";
        fetch(`https://${GetParentResourceName()}/kapat`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({})
        }).catch(e => debugError("/kapat fetch hatasi (ESC):", e));
    } else if (event.key === 'ArrowUp') {
        event.preventDefault();
        if (messageHistory.length > 0) {
            if (historyIndex === messageHistory.length) {
                currentInputValue = chatInput.value;
            }
            if (historyIndex > 0) {
                historyIndex--
                chatInput.value = messageHistory[historyIndex];
                chatInput.selectionStart = chatInput.selectionEnd = chatInput.value.length;
            }
        }
    } else if (event.key === 'ArrowDown') {
        event.preventDefault();
        if (messageHistory.length > 0) {
            if (historyIndex < messageHistory.length - 1) {
                historyIndex++
                chatInput.value = messageHistory[historyIndex];
                chatInput.selectionStart = chatInput.selectionEnd = chatInput.value.length;
            } else if (historyIndex === messageHistory.length - 1) {
                historyIndex++
                chatInput.value = currentInputValue;
                chatInput.selectionStart = chatInput.selectionEnd = chatInput.value.length;
            }
        }
    } else {
        historyIndex = messageHistory.length;
    }
});

function scrollChatToBottom() {
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

if (typeof GetParentResourceName === 'undefined') {
    window.GetParentResourceName = () => 'oekxc-chat';
} 