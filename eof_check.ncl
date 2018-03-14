; ==============================================================
; By Yu-Chiao @ UC-Irvine August 13, 2015
; ==============================================================
; Calculate 500 hPa GPH to determine TNH pattern
; ==============================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


  neof = 10
  optEOF = False
  optETS = False

; read data from eof output file

  f      = addfile ("./eof_ncl_temp/field_matlab_gph.nc", "r")
  field_matlab   = f->field_matlab

; replace nan points by 1.e20
  if (any(isnan_ieee(field_matlab))) then
      value = 1.e20
      replace_ieeenan (field_matlab, value, 0)
      field_matlab@_FillValue = value
  end if

  print(dimsizes(field_matlab))

;  sleep(1000000)

; end read file

  eof    = eofunc_Wrap(field_matlab, neof, optEOF)      
  eof_ts = eofunc_ts_Wrap (field_matlab, eof, optETS)
 
; =================================================================
; Perform varimax rotation
; =================================================================

  eof_rot = eofunc_varimax_Wrap( eof, 1 )
  printVarSummary( eof_rot )        
  print("eof_rot: min="+min(eof_rot)+"   max="+max(eof_rot) )

;  print(dimsizes(reof_ts))
;  sleep(100000)

; =================================================================
; put into descending order and calculate rotate pcs
; =================================================================

  eofunc_varimax_reorder( eof_rot )
  reof_ts = eofunc_ts_Wrap (field_matlab, eof_rot, optETS)
;  printVarSummary( eof_rot )        

;*******************************************
; Output eofs and rotate eofs
;*******************************************

  dim_eof = dimsizes(eof)
  n_eof = dim_eof(0)
  ny_eof = dim_eof(1)
  nx_eof = dim_eof(2)
  dim_pc  = dimsizes(eof_ts)
  n_ts = dim_pc(1)
  dim_varexp = dimsizes(eof@pcvar)
  n_varexp = dim_varexp
  diro = "./eof_ncl_temp/"
  filo = "eof_and_reof_ncl.nc"
  system("/bin/rm -f " + diro + filo)
  fout  = addfile (diro + filo, "c")  ; open output file

  varexp = eof@pcvar
  varexp_reof = eof_rot@pcvar_varimax

  setfileoption(fout,"DefineMode",True)

  fAtt = True            ; assign file attributes
  fAtt@title         = "NCL Efficient Approach to netCDF Creation"
  fAtt@source_file   =  "original-file.nc"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef(fout,fAtt)

;  dimNames = (/"time","lat","lon","evn"/)
;  dimSizes = (/n_ts,ny_eof,nx_eof,n_eof/)
;  dimUnlim = (/False,False,False,False/)
;  filedimdef(fout,dimNames,dimSizes,dimUnlim)

;  dimNames = (/"evn","lat","lon"/)
;  dimSizes = (/n_eof,ny_eof,nx_eof/)
;  dimUnlim = (/False,False,False/)
;  filedimdef(fout,dimNames,dimSizes,dimUnlim)

;  filevardef(fout,"eof",typeof(eof),getvardims(eof))
;  filevardef(fout,"eof_ts",typeof(eof_ts),getvardims(eof_ts))
;  filevardef(fout,"varexp",typeof(varexp),getvardims(varexp))
;  filevardef(fout,"eof_rot",typeof(eof_rot),getvardims(eof_rot))
;  filevardef(fout,"reof_ts",typeof(reof_ts),getvardims(reof_ts))
;  filevardef(fout,"varexp_reof",typeof(varexp_reof),getvardims(varexp_reof))

;  filevarattdef(fout,"eof",eof)
;  filevarattdef(fout,"eof_ts",eof_ts)
;  filevarattdef(fout,"varexp",varexp)
;  filevarattdef(fout,"eof_rot",eof_rot)
;  filevarattdef(fout,"reof_ts",reof_ts)
;  filevarattdef(fout,"varexp_reof",varexp_reof)


  setfileoption(fout,"DefineMode",False)

  fout->eof = (/eof/)
  fout->eof_ts = (/eof_ts/)
  fout->varexp = (/varexp/)
  fout->eof_rot = (/eof_rot/)
  fout->reof_ts = (/reof_ts/)
  fout->varexp_reof = (/varexp_reof/)


