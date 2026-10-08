-- Run in Supabase SQL Editor. Preserve the existing three-argument RPC signature.
-- Budget legacy RPC only accepts Budget codes; Gold uses separate product-specific RPC.
BEGIN;

CREATE OR REPLACE FUNCTION public.activate_planora(
 p_access_code text, p_device_token text, p_device_name text DEFAULT NULL::text
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
DECLARE
 v_license public.planora_licenses%rowtype;
 v_device_count integer;
BEGIN
 IF nullif(trim(p_access_code),'') IS NULL OR nullif(trim(p_device_token),'') IS NULL THEN
  RETURN jsonb_build_object('success',false,'message','Kode atau perangkat tidak valid.');
 END IF;
 SELECT l.* INTO v_license
 FROM public.planora_licenses l
 JOIN public.planora_products p ON p.id=l.product_id
 WHERE l.access_code=upper(trim(p_access_code)) AND p.code='BUDGET'
 FOR UPDATE OF l;
 IF NOT FOUND THEN
  RETURN jsonb_build_object('success',false,'message','Access code Budget tidak ditemukan.');
 END IF;
 IF v_license.status='disabled' THEN
  RETURN jsonb_build_object('success',false,'message','Access code dinonaktifkan.');
 END IF;
 IF EXISTS(SELECT 1 FROM public.planora_devices WHERE license_id=v_license.id AND device_token=p_device_token) THEN
  UPDATE public.planora_devices SET last_seen_at=now() WHERE license_id=v_license.id AND device_token=p_device_token;
  RETURN jsonb_build_object('success',true,'message','Welcome back to Planora.');
 END IF;
 SELECT count(*) INTO v_device_count FROM public.planora_devices WHERE license_id=v_license.id;
 IF v_device_count>=v_license.max_devices THEN
  RETURN jsonb_build_object('success',false,'message','Batas perangkat untuk access code ini sudah tercapai.');
 END IF;
 INSERT INTO public.planora_devices(license_id,device_token,device_name) VALUES(v_license.id,p_device_token,p_device_name);
 UPDATE public.planora_licenses SET status='active',first_activated_at=coalesce(first_activated_at,now()),last_activated_at=now() WHERE id=v_license.id;
 RETURN jsonb_build_object('success',true,'message','Planora Budget berhasil diaktifkan.');
END;
$function$;

CREATE OR REPLACE FUNCTION public.activate_planora_gold(
 p_access_code text, p_device_token text, p_device_name text DEFAULT NULL::text
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public'
AS $function$
DECLARE
 v_license public.planora_licenses%rowtype;
 v_device_count integer;
BEGIN
 IF nullif(trim(p_access_code),'') IS NULL OR nullif(trim(p_device_token),'') IS NULL THEN
  RETURN jsonb_build_object('success',false,'message','Kode atau perangkat tidak valid.');
 END IF;
 SELECT l.* INTO v_license
 FROM public.planora_licenses l
 JOIN public.planora_products p ON p.id=l.product_id
 WHERE l.access_code=upper(trim(p_access_code)) AND p.code='GOLD'
 FOR UPDATE OF l;
 IF NOT FOUND THEN
  RETURN jsonb_build_object('success',false,'message','Access code Gold tidak ditemukan.');
 END IF;
 IF v_license.status='disabled' THEN
  RETURN jsonb_build_object('success',false,'message','Access code dinonaktifkan.');
 END IF;
 IF EXISTS(SELECT 1 FROM public.planora_devices WHERE license_id=v_license.id AND device_token=p_device_token) THEN
  UPDATE public.planora_devices SET last_seen_at=now() WHERE license_id=v_license.id AND device_token=p_device_token;
  RETURN jsonb_build_object('success',true,'message','Welcome back to Planora Gold.');
 END IF;
 SELECT count(*) INTO v_device_count FROM public.planora_devices WHERE license_id=v_license.id;
 IF v_device_count>=v_license.max_devices THEN
  RETURN jsonb_build_object('success',false,'message','Batas perangkat untuk access code ini sudah tercapai.');
 END IF;
 INSERT INTO public.planora_devices(license_id,device_token,device_name) VALUES(v_license.id,p_device_token,p_device_name);
 UPDATE public.planora_licenses SET status='active',first_activated_at=coalesce(first_activated_at,now()),last_activated_at=now() WHERE id=v_license.id;
 RETURN jsonb_build_object('success',true,'message','Planora Gold berhasil diaktifkan.');
END;
$function$;
COMMIT;
