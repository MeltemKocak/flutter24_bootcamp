import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class only_text extends StatelessWidget {
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
                    padding: EdgeInsets.fromLTRB(13, 17, 19, 17),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 12, 2),
                                child: SizedBox(
                                  width: 110,
                                  child: Text(
                                    '18 April.',
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
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 17),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'First day of travel',
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
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 15.7, 0),
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
