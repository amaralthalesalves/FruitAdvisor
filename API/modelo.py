import numpy as np
import os
import cv2 as cv
import tensorflow as tf
from sklearn.utils import shuffle
from sklearn.metrics import classification_report, confusion_matrix
import seaborn as sn
import matplotlib.pyplot as plt
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# Diretórios de treino e teste
treino = 'C:\\Users\\mthbe\\OneDrive\\Documentos\\TCC\\Keras\\Dataset\\Training'
teste = 'C:\\Users\\mthbe\\OneDrive\\Documentos\\TCC\\Keras\\Dataset\\Test'

# Obtém os nomes das classes
nomes = [n for n in os.listdir(treino) if n != '.ipynb_checkpoints']
print(nomes)
numero_nomes = len(nomes)

indices = {nome: index for index, nome in enumerate(nomes)}

formato = (100, 100)

# Função para carregar imagens e rótulos
def carregar(diretorio):
    imagens, titulos = [], []
    for nome in nomes:
        diretorio_classes = os.path.join(diretorio, nome)
        for nome_arquivo in os.listdir(diretorio_classes):
            caminho = os.path.join(diretorio_classes, nome_arquivo)
            imagem = cv.imread(caminho)
            if imagem is None:
                print(f"Aviso: Arquivo ignorado ({caminho})")
                continue
            imagem = cv.cvtColor(imagem, cv.COLOR_BGR2RGB)
            imagem = cv.resize(imagem, formato)
            imagens.append(imagem)
            titulos.append(indices[nome])
    imagens = np.array(imagens, dtype='float32') / 255.0
    titulos = np.array(titulos, dtype='int32')
    return imagens, titulos

# Carrega os dados de treino e teste
imagens_treino, titulos_treino = carregar(treino)
imagens_teste, titulos_teste = carregar(teste)

# Embaralha os dados de treino
imagens_treino, titulos_treino = shuffle(imagens_treino, titulos_treino, random_state=25)

# Definir o aumento de dados (data augmentation)
data_gen = ImageDataGenerator(
    rescale=1.0/255.0,
    rotation_range=20,  # Rotações aleatórias de até 20 graus
    width_shift_range=0.2,  # Translação horizontal
    height_shift_range=0.2,  # Translação vertical
    shear_range=0.2,  # Alterações de cisalhamento
    zoom_range=0.2,  # Zoom aleatório
    horizontal_flip=True,  # Flip horizontal
    fill_mode='nearest'  # Preenchimento dos pixels após transformação
)

# Treinamento com aumento de dados
train_generator = data_gen.flow(imagens_treino, titulos_treino, batch_size=64)

# Modelo CNN
inputs = tf.keras.Input(shape=(100, 100, 3))
x = inputs
x = tf.keras.layers.Conv2D(16, (5, 5), activation='relu', padding='same')(x)
x = tf.keras.layers.BatchNormalization()(x)
x = tf.keras.layers.MaxPooling2D((2, 2), strides=2)(x)
x = tf.keras.layers.Conv2D(32, (5, 5), activation='relu', padding='same')(x)
x = tf.keras.layers.BatchNormalization()(x)
x = tf.keras.layers.MaxPooling2D((2, 2), strides=2)(x)
x = tf.keras.layers.Conv2D(64, (5, 5), activation='relu', padding='same')(x)
x = tf.keras.layers.BatchNormalization()(x)
x = tf.keras.layers.MaxPooling2D((2, 2), strides=2)(x)
x = tf.keras.layers.Conv2D(128, (5, 5), activation='relu', padding='same')(x)
x = tf.keras.layers.BatchNormalization()(x)
x = tf.keras.layers.MaxPooling2D((2, 2), strides=2)(x)
x = tf.keras.layers.Flatten()(x)
x = tf.keras.layers.Dense(1024, activation='relu')(x)
x = tf.keras.layers.Dropout(0.5)(x)
x = tf.keras.layers.Dense(256, activation='relu')(x)
x = tf.keras.layers.Dropout(0.5)(x)
outputs = tf.keras.layers.Dense(numero_nomes, activation='softmax')(x)

modelo = tf.keras.Model(inputs, outputs)
modelo.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
              loss='sparse_categorical_crossentropy', metrics=['accuracy'])

modelo.summary()

# Callbacks
programacao_taxa_de_aprendizado = tf.keras.callbacks.LearningRateScheduler(lambda epoch: 0.0001 * np.exp(-epoch / 10))
parada = tf.keras.callbacks.EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)

# Treinamento
history = modelo.fit(
    train_generator,  # Usando o gerador de dados com aumento
    epochs=10, 
    validation_data=(imagens_teste, titulos_teste), 
    callbacks=[parada, programacao_taxa_de_aprendizado]
)

# Função para visualizar precisão e perda
def precisao(history):
    fig = plt.figure(figsize=(10, 5))

    plt.subplot(221)
    plt.plot(history.history['accuracy'], 'bo--', label='acc')
    plt.plot(history.history['val_accuracy'], 'ro--', label='val_acc')
    plt.title('train_acc vs val_acc')
    plt.ylabel('accuracy')
    plt.xlabel('epochs')
    plt.legend()

    plt.subplot(222)
    plt.plot(history.history['loss'], 'bo--', label='loss')
    plt.plot(history.history['val_loss'], 'ro--', label='val_loss')
    plt.title('train_loss vs val_loss')
    plt.ylabel('loss')
    plt.xlabel('epochs')
    plt.legend()
    plt.show()

precisao(history)

# Avaliação no conjunto de teste
perda = modelo.evaluate(imagens_teste, titulos_teste)

# Previsões
predicoes = modelo.predict(imagens_teste)
titulos_predicao = np.argmax(predicoes, axis=1)

# Matriz de confusão
matriz_de_confusao = confusion_matrix(titulos_teste, titulos_predicao)
plt.figure(figsize=(12, 10))
sn.heatmap(matriz_de_confusao, annot=False, fmt='d', cmap='Blues', xticklabels=nomes, yticklabels=nomes)
plt.title('Confusion Matrix')
plt.xlabel('Predicted')
plt.ylabel('True')
plt.show()

# Relatório de classificação
print(classification_report(titulos_teste, titulos_predicao, target_names=nomes))

# Salvar modelo
tf.keras.models.save_model(modelo, 'C:\\Users\\mthbe\\OneDrive\\Documentos\\TCC\\Keras\\Modelo2_Keras_Dropout_BN.h5')
