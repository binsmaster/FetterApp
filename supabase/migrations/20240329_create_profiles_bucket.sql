-- Criar o bucket 'profiles' se ele não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('profiles', 'profiles', true)
ON CONFLICT (id) DO NOTHING;

-- Habilitar a extensão uuid-ossp se ainda não estiver habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Política para leitura pública
CREATE POLICY "Permitir leitura pública das imagens"
ON storage.objects FOR SELECT
USING (bucket_id = 'profiles');

-- Política para upload por usuários autenticados
CREATE POLICY "Permitir upload por usuários autenticados"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'profiles' 
    AND (owner::uuid = auth.uid())
);

-- Política para atualização pelo próprio usuário
CREATE POLICY "Permitir atualização pelo próprio usuário"
ON storage.objects FOR UPDATE
TO authenticated
USING (
    bucket_id = 'profiles' 
    AND owner::uuid = auth.uid()
)
WITH CHECK (
    bucket_id = 'profiles' 
    AND owner::uuid = auth.uid()
);

-- Política para deleção pelo próprio usuário
CREATE POLICY "Permitir deleção pelo próprio usuário"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'profiles' 
    AND owner::uuid = auth.uid()
);

-- Garantir que os metadados do usuário incluam os campos necessários
ALTER TABLE auth.users
ADD COLUMN IF NOT EXISTS raw_app_meta_data jsonb,
ADD COLUMN IF NOT EXISTS raw_user_meta_data jsonb; 