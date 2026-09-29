-- ============================================================================
-- PROJETO DE BANCO DE DADOS: PLATAFORMA DE STREAMING DE VÍDEOS
-- ============================================================================
USE master;
GO
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DB_PLATAFORMA_STREAMING')
BEGIN
    ALTER DATABASE DB_PLATAFORMA_STREAMING SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DB_PLATAFORMA_STREAMING;
END
GO
CREATE DATABASE DB_PLATAFORMA_STREAMING;
GO
USE DB_PLATAFORMA_STREAMING;
GO
SET DATEFORMAT ymd;
GO

-- 2 CRIAÇÃO DAS TABELAS 

-- Tabela: PAIS
CREATE TABLE PAIS (
    id_pais INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    CONSTRAINT PK_PAIS PRIMARY KEY (id_pais),
    CONSTRAINT UQ_PAIS_NOME UNIQUE (nome)
);

-- Tabela: ESTADO
CREATE TABLE ESTADO (
    id_estado INT IDENTITY(1,1) NOT NULL,
    id_pais INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    sigla CHAR(2) NOT NULL,
    CONSTRAINT PK_ESTADO PRIMARY KEY (id_estado),
    CONSTRAINT FK_ESTADO_PAIS FOREIGN KEY (id_pais) REFERENCES PAIS(id_pais),
    CONSTRAINT UQ_ESTADO_PAIS_SIGLA UNIQUE (id_pais, sigla)
);
-- Tabela: CIDADE
CREATE TABLE CIDADE (
    id_cidade INT IDENTITY(1,1) NOT NULL,
    id_estado INT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    CONSTRAINT PK_CIDADE PRIMARY KEY (id_cidade),
    CONSTRAINT FK_CIDADE_ESTADO FOREIGN KEY (id_estado) REFERENCES ESTADO(id_estado),
    CONSTRAINT UQ_CIDADE_ESTADO_NOME UNIQUE (id_estado, nome)
);
-- Tabela: BAIRRO
CREATE TABLE BAIRRO (
    id_bairro INT IDENTITY(1,1) NOT NULL,
    id_cidade INT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    CONSTRAINT PK_BAIRRO PRIMARY KEY (id_bairro),
    CONSTRAINT FK_BAIRRO_CIDADE FOREIGN KEY (id_cidade) REFERENCES CIDADE(id_cidade),
    CONSTRAINT UQ_BAIRRO_CIDADE_NOME UNIQUE (id_cidade, nome)
);
-- Tabela: USUARIO
CREATE TABLE USUARIO (
    id_usuario INT IDENTITY(1,1) NOT NULL,
    id_bairro INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    data_cadastro DATETIME NOT NULL CONSTRAINT DF_USUARIO_DATA_CADASTRO DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL CONSTRAINT DF_USUARIO_STATUS DEFAULT 'ATIVO',
    CONSTRAINT PK_USUARIO PRIMARY KEY (id_usuario),
    CONSTRAINT FK_USUARIO_BAIRRO FOREIGN KEY (id_bairro) REFERENCES BAIRRO(id_bairro),
    CONSTRAINT UQ_USUARIO_EMAIL UNIQUE (email),
    CONSTRAINT CK_USUARIO_STATUS CHECK (status IN ('ATIVO', 'INATIVO', 'BLOQUEADO'))
);
-- Tabela: PERFIL
CREATE TABLE PERFIL (
    id_perfil INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    data_nascimento DATE NULL,
    avatar VARCHAR(255) NULL,
    infantil BIT NOT NULL CONSTRAINT DF_PERFIL_INFANTIL DEFAULT 0,
    CONSTRAINT PK_PERFIL PRIMARY KEY (id_perfil),
    CONSTRAINT FK_PERFIL_USUARIO FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
    CONSTRAINT UQ_PERFIL_USUARIO_NOME UNIQUE (id_usuario, nome)
);

-- Tabela: DISPOSITIVO
CREATE TABLE DISPOSITIVO (
    id_dispositivo INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    sistema_operacional VARCHAR(100) NULL,
    ultimo_acesso DATETIME NULL,
    CONSTRAINT PK_DISPOSITIVO PRIMARY KEY (id_dispositivo),
    CONSTRAINT FK_DISPOSITIVO_USUARIO FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario)
);

-- Tabela: PLANO
CREATE TABLE PLANO (
    id_plano INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(50) NOT NULL,
    valor_mensal DECIMAL(10,2) NOT NULL,
    quantidade_telas INT NOT NULL,
    qualidade_video VARCHAR(20) NOT NULL,
    CONSTRAINT PK_PLANO PRIMARY KEY (id_plano),
    CONSTRAINT UQ_PLANO_NOME UNIQUE (nome),
    CONSTRAINT CK_PLANO_VALOR CHECK (valor_mensal >= 0),
    CONSTRAINT CK_PLANO_TELAS CHECK (quantidade_telas > 0)
);

-- Tabela: ASSINATURA
CREATE TABLE ASSINATURA (
    id_assinatura INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    id_plano INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NULL,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT PK_ASSINATURA PRIMARY KEY (id_assinatura),
    CONSTRAINT FK_ASSINATURA_USUARIO FOREIGN KEY (id_usuario) REFERENCES USUARIO(id_usuario),
    CONSTRAINT FK_ASSINATURA_PLANO FOREIGN KEY (id_plano) REFERENCES PLANO(id_plano),
    CONSTRAINT CK_ASSINATURA_STATUS CHECK (status IN ('ATIVA', 'CANCELADA', 'EXPIRADA', 'SUSPENSA')),
    CONSTRAINT CK_ASSINATURA_DATAS CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- Tabela: PAGAMENTO
CREATE TABLE PAGAMENTO (
    id_pagamento INT IDENTITY(1,1) NOT NULL,
    id_assinatura INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    data_pagamento DATE NOT NULL,
    forma_pagamento VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT PK_PAGAMENTO PRIMARY KEY (id_pagamento),
    CONSTRAINT FK_PAGAMENTO_ASSINATURA FOREIGN KEY (id_assinatura) REFERENCES ASSINATURA(id_assinatura),
    CONSTRAINT CK_PAGAMENTO_VALOR CHECK (valor >= 0),
    CONSTRAINT CK_PAGAMENTO_STATUS CHECK (status IN ('PENDENTE', 'PAGO', 'RECUSADO', 'ESTORNADO'))
);

-- Tabela: CONTEUDO
CREATE TABLE CONTEUDO (
    id_conteudo INT IDENTITY(1,1) NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    sinopse VARCHAR(500) NULL,
    tipo VARCHAR(20) NOT NULL,
    ano_lancamento INT NULL,
    duracao_minutos INT NULL,
    classificacao VARCHAR(20) NULL,
    idioma_original VARCHAR(50) NULL,
    CONSTRAINT PK_CONTEUDO PRIMARY KEY (id_conteudo),
    CONSTRAINT CK_CONTEUDO_TIPO CHECK (tipo IN ('FILME', 'SERIE')),
    CONSTRAINT CK_CONTEUDO_ANO CHECK (ano_lancamento IS NULL OR ano_lancamento >= 1888),
    CONSTRAINT CK_CONTEUDO_DURACAO CHECK (duracao_minutos IS NULL OR duracao_minutos > 0)
);

-- Tabela: GENERO
CREATE TABLE GENERO (
    id_genero INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(80) NOT NULL,
    CONSTRAINT PK_GENERO PRIMARY KEY (id_genero),
    CONSTRAINT UQ_GENERO_NOME UNIQUE (nome)
);

-- Tabela: CONTEUDO_GENERO 
CREATE TABLE CONTEUDO_GENERO (
    id_conteudo INT NOT NULL,
    id_genero INT NOT NULL,
    CONSTRAINT PK_CONTEUDO_GENERO PRIMARY KEY (id_conteudo, id_genero),
    CONSTRAINT FK_CONTEUDO_GENERO_CONTEUDO FOREIGN KEY (id_conteudo) REFERENCES CONTEUDO(id_conteudo),
    CONSTRAINT FK_CONTEUDO_GENERO_GENERO FOREIGN KEY (id_genero) REFERENCES GENERO(id_genero)
);

-- Tabela: TEMPORADA
CREATE TABLE TEMPORADA (
    id_temporada INT IDENTITY(1,1) NOT NULL,
    id_conteudo INT NOT NULL,
    numero INT NOT NULL,
    ano_lancamento INT NULL,
    CONSTRAINT PK_TEMPORADA PRIMARY KEY (id_temporada),
    CONSTRAINT FK_TEMPORADA_CONTEUDO FOREIGN KEY (id_conteudo) REFERENCES CONTEUDO(id_conteudo),
    CONSTRAINT UQ_TEMPORADA_CONTEUDO_NUMERO UNIQUE (id_conteudo, numero),
    CONSTRAINT CK_TEMPORADA_NUMERO CHECK (numero > 0)
);

-- Tabela: EPISODIO
CREATE TABLE EPISODIO (
    id_episodio INT IDENTITY(1,1) NOT NULL,
    id_temporada INT NOT NULL,
    numero INT NOT NULL,
    titulo VARCHAR(200) NOT NULL,
    sinopse VARCHAR(500) NULL,
    duracao_minutos INT NOT NULL,
    CONSTRAINT PK_EPISODIO PRIMARY KEY (id_episodio),
    CONSTRAINT FK_EPISODIO_TEMPORADA FOREIGN KEY (id_temporada) REFERENCES TEMPORADA(id_temporada),
    CONSTRAINT UQ_EPISODIO_TEMPORADA_NUMERO UNIQUE (id_temporada, numero),
    CONSTRAINT CK_EPISODIO_NUMERO CHECK (numero > 0),
    CONSTRAINT CK_EPISODIO_DURACAO CHECK (duracao_minutos > 0)
);

-- Tabela: PESSOA_ELENCO
CREATE TABLE PESSOA_ELENCO (
    id_pessoa INT IDENTITY(1,1) NOT NULL,
    nome VARCHAR(150) NOT NULL,
    data_nascimento DATE NULL,
    nacionalidade VARCHAR(80) NULL,
    CONSTRAINT PK_PESSOA_ELENCO PRIMARY KEY (id_pessoa)
);

-- Tabela: CONTEUDO_ELENCO 
CREATE TABLE CONTEUDO_ELENCO (
    id_conteudo INT NOT NULL,
    id_pessoa INT NOT NULL,
    personagem VARCHAR(150) NULL,
    CONSTRAINT PK_CONTEUDO_ELENCO PRIMARY KEY (id_conteudo, id_pessoa),
    CONSTRAINT FK_CONTEUDO_ELENCO_CONTEUDO FOREIGN KEY (id_conteudo) REFERENCES CONTEUDO(id_conteudo),
    CONSTRAINT FK_CONTEUDO_ELENCO_PESSOA FOREIGN KEY (id_pessoa) REFERENCES PESSOA_ELENCO(id_pessoa)
);

-- Tabela: HISTORICO_VISUALIZACAO
CREATE TABLE HISTORICO_VISUALIZACAO (
    id_historico INT IDENTITY(1,1) NOT NULL,
    id_perfil INT NOT NULL,
    id_conteudo INT NOT NULL,
    id_episodio INT NULL,
    data_inicio DATETIME NOT NULL,
    data_fim DATETIME NULL,
    progresso_segundos INT NOT NULL CONSTRAINT DF_HISTORICO_PROGRESSO DEFAULT 0,
    percentual_assistido DECIMAL(5,2) NOT NULL CONSTRAINT DF_HISTORICO_PERCENTUAL DEFAULT 0,
    CONSTRAINT PK_HISTORICO_VISUALIZACAO PRIMARY KEY (id_historico),
    CONSTRAINT FK_HISTORICO_PERFIL FOREIGN KEY (id_perfil) REFERENCES PERFIL(id_perfil),
    CONSTRAINT FK_HISTORICO_CONTEUDO FOREIGN KEY (id_conteudo) REFERENCES CONTEUDO(id_conteudo),
    CONSTRAINT FK_HISTORICO_EPISODIO FOREIGN KEY (id_episodio) REFERENCES EPISODIO(id_episodio),
    CONSTRAINT CK_HISTORICO_PROGRESSO CHECK (progresso_segundos >= 0),
    CONSTRAINT CK_HISTORICO_PERCENTUAL CHECK (percentual_assistido BETWEEN 0 AND 100),
    CONSTRAINT CK_HISTORICO_DATAS CHECK (data_fim IS NULL OR data_fim >= data_inicio)
);

-- Tabela: AVALIACAO
CREATE TABLE AVALIACAO (
    id_avaliacao INT IDENTITY(1,1) NOT NULL,
    id_perfil INT NOT NULL,
    id_conteudo INT NOT NULL,
    nota INT NOT NULL,
    comentario VARCHAR(500) NULL,
    data_avaliacao DATETIME NOT NULL CONSTRAINT DF_AVALIACAO_DATA DEFAULT GETDATE(),
    CONSTRAINT PK_AVALIACAO PRIMARY KEY (id_avaliacao),
    CONSTRAINT FK_AVALIACAO_PERFIL FOREIGN KEY (id_perfil) REFERENCES PERFIL(id_perfil),
    CONSTRAINT FK_AVALIACAO_CONTEUDO FOREIGN KEY (id_conteudo) REFERENCES CONTEUDO(id_conteudo),
    CONSTRAINT UQ_AVALIACAO_PERFIL_CONTEUDO UNIQUE (id_perfil, id_conteudo),
    CONSTRAINT CK_AVALIACAO_NOTA CHECK (nota BETWEEN 1 AND 5)
);

-- Tabela: MINHA_LISTA 
CREATE TABLE MINHA_LISTA (
    id_perfil INT NOT NULL,
    id_conteudo INT NOT NULL,
    data_adicao DATETIME NOT NULL CONSTRAINT DF_MINHA_LISTA_DATA DEFAULT GETDATE(),
    CONSTRAINT PK_MINHA_LISTA PRIMARY KEY (id_perfil, id_conteudo),
    CONSTRAINT FK_MINHA_LISTA_PERFIL FOREIGN KEY (id_perfil) REFERENCES PERFIL(id_perfil),
    CONSTRAINT FK_MINHA_LISTA_CONTEUDO FOREIGN KEY (id_conteudo) REFERENCES CONTEUDO(id_conteudo)
);

-- 3 INSERÇÃO DE DADOS DE EXEMPLO 

SET DATEFORMAT ymd;

-- Inserindo dados na tabela PAIS
INSERT INTO PAIS (nome)
VALUES ('Brasil'),('Argentina'),('Grecia'),('Japao'),('Nova Zelandia');

-- Inserindo dados na tabela ESTADO
INSERT INTO ESTADO (id_pais, nome, sigla)
VALUES (1, 'Sao Paulo', 'SP'),(2, 'Buenos Aires', 'BA'),(3, 'Atica', 'AT'),
(4, 'Toquio', 'TK'),(5, 'Wellington', 'WG');

-- Inserindo dados na tabela CIDADE
INSERT INTO CIDADE (id_estado, nome)
VALUES (1, 'Campinas'),(2, 'Buenos Aires'),(3, 'Atenas'),(4, 'Toquio'),(5, 'Wellington');


-- Inserindo dados na tabela BAIRRO
INSERT INTO BAIRRO (id_cidade, nome)
VALUES (1, 'Taquaral'),(2, 'Palermo'),(3, 'Plaka'),(4, 'Shinjuku'),(5, 'Mount Victoria');

-- Inserindo dados na tabela USUARIO
INSERT INTO USUARIO (id_bairro, nome, email, senha, data_nascimento, data_cadastro, status)
VALUES 
(1, 'Julia Silva', 'julia@email.com', 'senha_julia_001', '2004-10-21', '2026-01-10 10:00:00', 'ATIVO'),
(2, 'Mariano Gomez', 'mariano@email.com', 'senha_mariano_002', '2010-07-04', '2026-02-05 14:30:00', 'BLOQUEADO'),
(3, 'Caio Ribeiro', 'caio@email.com', 'senha_caio_003', '2000-11-08', '2026-02-19 09:15:00', 'ATIVO'),
(4, 'Silvana Santos', 'silvana@email.com', 'senha_silvana_004', '1980-10-30', '2026-03-01 18:20:00', 'INATIVO'),
(5, 'Tony Stark', 'tony.stark@email.com', 'senha_tony_005', '1984-08-12', '2026-03-12 20:45:00', 'ATIVO');

-- Inserindo dados na tabela PERFIL
INSERT INTO PERFIL (id_usuario, nome, data_nascimento, avatar, infantil)
VALUES 
(1, 'Julia', '2004-10-21', 'avatar_julia.png', 0),
(1, 'Familia', NULL, 'avatar_familia.png', 0),
(2, 'Mariano', '2010-07-04', 'avatar_mariano.png', 0),
(3, 'Caio', '2000-11-08', 'avatar_caio.png', 0),
(4, 'Silvana', '1980-10-30', 'avatar_silvana.png', 0),
(5, 'Tony', '1984-08-12', 'avatar_tony.png', 0),
(5, 'Kids', NULL, 'avatar_kids.png', 1);

-- Inserindo dados na tabela DISPOSITIVO
INSERT INTO DISPOSITIVO (id_usuario, nome, tipo, sistema_operacional, ultimo_acesso)
VALUES 
(1, 'Celular Julia', 'SMARTPHONE', 'Android', '2026-09-20 20:30:00'),
(2, 'Celular Mariano', 'SMARTPHONE', 'Android', '2026-09-21 18:15:00'),
(3, 'Notebook Caio', 'NOTEBOOK', 'Windows 11', '2026-09-22 21:40:00'),
(4, 'Smart TV Silvana', 'SMART TV', 'Tizen', '2026-09-23 19:20:00'),
(5, 'Notebook Tony', 'NOTEBOOK', 'Windows 11', '2026-09-24 20:00:00');

-- Inserindo dados na tabela PLANO
INSERT INTO PLANO (nome, valor_mensal, quantidade_telas, qualidade_video)
VALUES 
('Basico', 16.90, 1, 'HD'),
('Padrao', 24.90, 2, 'FULL HD'),
('Premium', 49.90, 4, '4K'),
('Familia', 59.90, 5, '4K'),
('Mobile', 14.90, 1, 'HD');

-- Inserindo dados na tabela ASSINATURA
INSERT INTO ASSINATURA (id_usuario, id_plano, data_inicio, data_fim, status)
VALUES 
(1, 2, '2026-01-10', NULL, 'ATIVA'),
(2, 5, '2026-02-05', NULL, 'SUSPENSA'),
(3, 1, '2026-02-19', NULL, 'ATIVA'),
(4, 3, '2026-03-01', NULL, 'EXPIRADA'),
(5, 4, '2026-03-12', NULL, 'ATIVA');

-- Inserindo dados na tabela PAGAMENTO
INSERT INTO PAGAMENTO (id_assinatura, valor, data_pagamento, forma_pagamento, status)
VALUES 
(1, 24.90, '2026-09-10', 'CARTAO DE CREDITO', 'PAGO'),
(2, 14.90, '2026-09-05', 'PIX', 'RECUSADO'),
(3, 16.90, '2026-09-19', 'CARTAO DE DEBITO', 'PAGO'),
(4, 49.90, '2026-09-01', 'CARTAO DE CREDITO', 'PENDENTE'),
(5, 59.90, '2026-09-12', 'CARTAO DE CREDITO', 'PAGO');

-- Inserindo dados na tabela CONTEUDO
INSERT INTO CONTEUDO (titulo, sinopse, tipo, ano_lancamento, duracao_minutos, classificacao, idioma_original)
VALUES 
('Corredor Infinito', 'Uma garota se ve presa num corredor sem fim e encara um terror psicologico.', 'FILME', 2026, 114, '18', 'Portugues'),
('Homem aranha', 'Peter parker e picado por uma aranha e recebe super poderes, lidando com responsabilidade de salvar o mundo.', 'FILME', 2026, 124, '16', 'Ingles'),
('V de vinganca', 'Uma garota e sequestrada e apos escapar vai em busca de vinganca.', 'FILME', 2016, 84, '16', 'Ingles'),
('Harry Potter', 'Harry Potter descobre ser um bruxo e ingressa na Escola de Magia e Bruxaria de Hogwarts.', 'FILME', 2022, 136, '16', 'Ingles'),
('True blood', 'Uma mulher vive numa cidade cercada por vampiros e se envolve com dois ao mesmo tempo.', 'SERIE', 2000, 60, '14', 'Portugues');

-- Inserindo dados na tabela GENERO
INSERT INTO GENERO (nome)
VALUES ('Terror'),('Acao'),('Suspense'),('Aventura'),('Ficcao cientifica');

-- Inserindo dados na tabela CONTEUDO_GENERO
INSERT INTO CONTEUDO_GENERO (id_conteudo, id_genero)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 1);

-- Inserindo dados na tabela TEMPORADA
INSERT INTO TEMPORADA (id_conteudo, numero, ano_lancamento)
VALUES 
(5, 1, 2016),
(5, 2, 2017),
(5, 3, 2018),
(5, 4, 2019),
(5, 5, 2020),
(5, 6, 2021);

-- Inserindo dados na tabela EPISODIO
INSERT INTO EPISODIO (id_temporada, numero, titulo, sinopse, duracao_minutos)
VALUES 
(1, 1, 'O Inicio', 'Um acontecimento inesperado inicia uma investigacao.', 48),
(1, 2, 'Novas Pistas', 'Novas informacoes surgem durante a investigacao.', 51),
(2, 3, 'O Retorno', 'Os acontecimentos anteriores voltam a influenciar a cidade.', 52),
(3, 4, 'O Primeiro Adeus', 'Sokie lida com a morte de skar.', 55),
(4, 5, 'Nova Era', 'Sokie descobre novos poderes.', 57),
(5, 8, 'A Origem', 'Sokie descobre a verdade sobre sua origem.', 57),
(6, 9, 'Revenge', 'Uma batalha sangrenta entre o lobo e o vampiro apaixonado.', 57);

-- Inserindo dados na tabela PESSOA_ELENCO
INSERT INTO PESSOA_ELENCO (nome, data_nascimento, nacionalidade)
VALUES 
('Alba Baptista', '1995-04-12', 'Brasileira'),
('Juliana Rocha', '1990-09-25', 'Brasileira'),
('Michael Jackson', '1982-01-17', 'Americana'),
('Sofia Vergara', '1993-06-05', 'Portuguesa'),
('Kenji Nakamura', '1987-11-21', 'Japonesa');

-- Inserindo dados na tabela CONTEUDO_ELENCO
INSERT INTO CONTEUDO_ELENCO (id_conteudo, id_pessoa, personagem)
VALUES 
(1, 2, 'Emma Clark'),
(2, 3, 'Peter Parker'),
(3, 2, 'Margaret'),
(4, 5, 'Neville'),
(5, 1, 'Sokie');

-- Inserindo dados na tabela HISTORICO_VISUALIZACAO
INSERT INTO HISTORICO_VISUALIZACAO (id_perfil, id_conteudo, id_episodio, data_inicio, data_fim, progresso_segundos, percentual_assistido)
VALUES 
(1, 1, NULL, '2026-09-20 20:00:00', '2026-09-20 22:12:00', 7920, 100.00),
(2, 2, NULL, '2026-09-21 19:00:00', '2026-09-21 19:48:00', 2880, 100.00),
(3, 3, NULL, '2026-09-22 21:00:00', '2026-09-22 22:58:00', 7080, 100.00),
(4, 4, NULL, '2026-09-23 20:30:00', '2026-09-23 21:15:00', 2700, 81.82),
(5, 5, 2, '2026-09-24 18:00:00', '2026-09-24 19:00:00', 3600, 48.00);

-- Inserindo dados na tabela AVALIACAO
INSERT INTO AVALIACAO (id_perfil, id_conteudo, nota, comentario, data_avaliacao)
VALUES 
(1, 1, 5, 'Excelente producao, suspense muito bem construido.', '2026-09-20 22:15:00'),
(2, 2, 5, 'Melhor filme de heroi que assisti este ano.', '2026-09-21 19:50:00'),
(3, 3, 4, 'Otimo filme, narrativa empolgante.', '2026-09-22 23:00:00'),
(4, 4, 4, 'Historia muito boa, marcou minha infancia.', '2026-09-23 21:20:00'),
(5, 5, 2, 'Serie razoavel, ritmo lento no inicio.', '2026-09-24 19:05:00');

-- Inserindo dados na tabela MINHA_LISTA
INSERT INTO MINHA_LISTA (id_perfil, id_conteudo, data_adicao)
VALUES 
(1, 2, '2026-09-10 10:00:00'),
(2, 3, '2026-09-11 11:30:00'),
(3, 4, '2026-09-12 15:20:00'),
(4, 5, '2026-09-13 18:45:00'),
(5, 1, '2026-09-14 20:10:00');

-- 4. CONSULTA XML 1: RELATÓRIO FINANCEIRO E DE ASSINATURAS DE CLIENTES

SELECT 
    UPPER(TRIM(u.nome)) AS cliente_nome,
    LOWER(u.email) AS cliente_email,
    p.nome AS plano_nome,
    p.qualidade_video AS plano_qualidade,
    pg.forma_pagamento AS forma_pagamento,
    FORMAT(pg.data_pagamento, 'dd/MM/yyyy') AS data_pagamento,
    pg.valor AS valor_pago,
    DATEDIFF(day, a.data_inicio, GETDATE()) AS dias_de_assinatura
FROM USUARIO AS u
INNER JOIN ASSINATURA AS a ON u.id_usuario = a.id_usuario
INNER JOIN PLANO AS p ON a.id_plano = p.id_plano
INNER JOIN PAGAMENTO AS pg ON a.id_assinatura = pg.id_assinatura
WHERE a.status = 'ATIVA'
  AND pg.status = 'PAGO'
  AND (p.valor_mensal >= 20.00 OR pg.forma_pagamento = 'CARTAO DE CREDITO')
  AND NOT (u.status = 'BLOQUEADO')
FOR XML PATH('assinatura_cliente'), ROOT('relatorio_assinaturas');
GO

--5. CONSULTA XML 2: RELATÓRIO DE AVALIAÇÕES E ENGAJAMENTO DE CATÁLOGO

SELECT 
    UPPER(c.titulo) AS titulo_conteudo,
    c.tipo AS tipo_conteudo,
    g.nome AS genero_principal,
    pf.nome AS nome_perfil,
    ROUND(av.nota * 1.0, 1) AS nota_avaliacao,
    ISNULL(av.comentario, 'Sem comentario registrado') AS comentario_avaliacao,
    YEAR(av.data_avaliacao) AS ano_avaliacao,
    CONCAT('Classificacao: ', c.classificacao, ' anos') AS faixa_etaria
FROM CONTEUDO AS c
INNER JOIN CONTEUDO_GENERO AS cg ON c.id_conteudo = cg.id_conteudo
INNER JOIN GENERO AS g ON cg.id_genero = g.id_genero
INNER JOIN AVALIACAO AS av ON c.id_conteudo = av.id_conteudo
INNER JOIN PERFIL AS pf ON av.id_perfil = pf.id_perfil
WHERE av.nota >= 4
  AND (c.tipo = 'FILME' OR c.duracao_minutos > 60)
  AND NOT (pf.infantil = 1)
FOR XML PATH('avaliacao_conteudo'), ROOT('relatorio_avaliacoes');
GO