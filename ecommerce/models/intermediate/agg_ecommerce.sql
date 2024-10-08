WITH
fact_vendas AS (
    SELECT
        id_venda,
        id_cliente,
        id_vendedor,
        id_unidade,
        id_produto,
        data_venda,
        quantidade,
        cupom_desconto,
        tipo_loja,
        tipo_pagamento
    FROM {{ ref('fact_vendas') }}
),

dim_vendedores AS (
    SELECT
        id_vendedor,
        nome_vendedor
    FROM {{ ref('dim_vendedores') }}
),

dim_unidades AS (
    SELECT
        id_unidade,
        cidade
    FROM {{ ref('dim_unidades') }}
),

dim_produtos AS (
    SELECT
        id_produto,
        nome_produto,
        preco_produto
    FROM {{ ref('dim_produtos') }}
),

dim_clientes AS (
    SELECT
        id_cliente,
        id_unidade,
        nome_cliente,
        endereco_cliente,
        telefone_cliente,
        email_cliente
    FROM {{ ref('dim_clientes') }}
),

dim_desconto AS (
    SELECT
    cupom,
    valor
    FROM {{ ref('desconto') }}

)


SELECT
    -- Fact table (fact_vendas)
    fv.id_venda,
    fv.id_cliente,
    fv.id_vendedor,
    fv.id_unidade,
    fv.id_produto,
    fv.data_venda,
    fv.quantidade,
    fv.cupom_desconto,
    (fv.quantidade * dp.preco_produto) * (1 - COALESCE(ds.valor, 0)) AS total_venda,
    fv.tipo_loja,
    fv.tipo_pagamento,


    -- Dimensão Produtos (dim_produtos)
    dp.nome_produto,
    dp.preco_produto,

    -- Dimensão Vendedores (dim_vendedores)
    dv.nome_vendedor,


    -- Dimensão Unidades (dim_unidades)
    du.cidade,

    -- Dimensão Clientes (dim_clientes)
    dc.nome_cliente,
    dc.endereco_cliente,
    dc.telefone_cliente,
    dc.email_cliente

FROM fact_vendas fv
LEFT JOIN dim_vendedores dv ON fv.id_vendedor = dv.id_vendedor
LEFT JOIN dim_unidades du ON fv.id_unidade = du.id_unidade
LEFT JOIN dim_produtos dp ON fv.id_produto = dp.id_produto
LEFT JOIN dim_clientes dc ON fv.id_cliente = dc.id_cliente
LEFT JOIN dim_desconto ds ON CAST(fv.cupom_desconto AS text) = ds.cupom
