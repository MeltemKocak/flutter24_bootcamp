import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class only_text extends StatelessWidget {
  const only_text({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
                      Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 17),
                child: Container(
                  decoration:  BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: const LinearGradient(
                      begin: Alignment(-1, 0),
                      end: Alignment(1, 0),
                      colors: <Color>[Color(0xFF004942), Color(0xFF005C54), Color.fromARGB(166, 1, 143, 131), Color.fromARGB(156, 3, 218, 197)],
                      stops: <double>[0.331, 0.536, 0.821, 1],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(13, 17, 19, 17),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 12, 2),
                                child: SizedBox(
                                  width: 110,
                                  child: Text(
                                    '18 April.',
                                    style: GoogleFonts.getFont(
                                      'Exo 2',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 24,
                                      height: 1,
                                      color: const Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 26,
                                padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: const Color(0x1AFFFFFF)),
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
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),
                                      
                                      const SizedBox(width: 1,),

                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle
                                          ),),

                                      ),

                                      const SizedBox(width: 1,),

                                      SizedBox(
                                        width: 2,
                                        height: 2,
                                        child: Container(
                                          width: 1,
                                          height: 1,
                                          decoration: const BoxDecoration(
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
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 17),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'First day of travel',
                              style: GoogleFonts.getFont(
                                'Exo 2',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                height: 1,
                                color: const Color(0xFFFFFFFF),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 15.7, 0),
                          child: Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid unt ut labore et dolore magna aliqua. Ut enon ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dol.',
                            style: GoogleFonts.getFont(
                              'Exo 2',
                              fontWeight: FontWeight.w200,
                              fontSize: 14,
                              height: 1,
                              color: const Color(0xFFFFFFFF),
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
