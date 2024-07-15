import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class voice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
                                    Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 17),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF2B373F),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(19, 17, 21, 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 1, 12, 1),
                                child: SizedBox(
                                  width: 110,
                                  child: Text(
                                    '13 May',
                                    style: GoogleFonts.getFont(
                                      'Exo 2',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                      height: 1,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 26,
                                padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0x1AFFFFFF)),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: 
                                SizedBox(
                                  width: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),
                                      
                                      SizedBox(width: 1,),

                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),

                                      SizedBox(width: 1,),

                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 11),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Boring Days',
                              style: GoogleFonts.getFont(
                                'Exo 2',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                height: 1,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(),

                        Container(
                          margin: EdgeInsets.fromLTRB(3.7, 8, 0, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10.3, 10.7, 7.3),
                                width: 32,
                                height: 32,
                                child: 
                                SizedBox(
                                  width: 18.7,
                                  height: 25.3,
                                  child: Icon(
                                    Icons.mic_sharp,
                                    color: Colors.white,
                                    size:32,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 18, 2, 18),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 7,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 14, 2.5, 14),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 15,
                                        ),
                                      ),
                                    ),
                                    /*Container(
                                      margin: EdgeInsets.fromLTRB(0, 10, 2.5, 11),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: 4,
                                          height: 22,
                                          //child: ,
                                        ),
                                      ),
                                    ),*/
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 6, 3, 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 11, 3, 12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 6, 3, 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 1, 3, 2),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 9, 3, 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 26,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 1, 3, 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 42,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 7, 3, 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 12, 3, 11),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 7, 3, 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 2, 3, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 9, 3, 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 26,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 1, 3, 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 42,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 7, 3, 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 12, 3, 11),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 7, 3, 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 2, 3, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 9, 3, 8),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 26,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 1, 3, 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 42,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 7, 3, 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 12, 3, 11),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 7, 3, 6),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 2, 3, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 8, 3, 9),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 26,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 3, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 42,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 6, 3, 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 11, 3, 12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 6, 3, 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 1, 3, 2),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 40,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 8, 3, 9),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 26,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 3, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 42,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 6, 3, 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 11, 3, 12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 20,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 6, 3, 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                    
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 8, 3, 9),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 26,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 3, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 42,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 6, 3, 7),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                                                   
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 10, 0, 11),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFD9D9D9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Container(
                                          width: 4,
                                          height: 22,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 7.7, 11),
                          child: Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid unt ut labore et dolore magna aliqua. Ut enon ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dol.',
                            style: GoogleFonts.getFont(
                              'Exo 2',
                              fontWeight: FontWeight.w200,
                              fontSize: 14,
                              height: 1,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
